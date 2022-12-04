# Check if crystal is in the path
unless system "crystal --version"
  raise "crystal is not in the path"
end

require_relative 'crywasm/sexp'
require 'tempfile'
require 'wasmer'

module CryWasm
  def method_added(name)
    return super(name) unless @crywasm_flag

    ruby_code_block, arg_names = @s_expression.extract_source_with_arguments(name, @line_number)
    crystal_args = arg_names.zip(@crystal_arg_types).map { |n, t| "#{n} : #{t}" }.join(', ')
    crystal_define_fun = "fun #{name}(#{crystal_args}) : #{@crystal_ret_type}\n"
    crystal_code_block = ruby_code_block.lines[1..].unshift(crystal_define_fun).join
    @crystal_code_blocks << crystal_code_block

    @marked_methods << name
    @line_number = 0
    @crywasm_flag = false

    super(name)
  end

  def cry(arg_types, ret_type)
    fname, l = caller[0].split(':')
    # In most cases, previously parsed S-expressions can be reused.
    if fname != @fname
      @s_expression = Sexp.new(fname)
      @fname = fname
    end
    # Searches for methods that appear on a line later than cry was called.
    @line_number = l.to_i
    @crywasm_flag = true
    @crystal_arg_types = validate_type_names(arg_types)
    @crystal_ret_type = validate_type_name(ret_type)
  end

  VALID_CRYSTAL_TYPES = %i[Int8 UInt8 Int16 UInt16 Int32 UInt32 Int64 UInt64].freeze

  def validate_type_names(type_names)
    type_names.map { |t| validate_type_name(t) }
  end

  def validate_type_name(type_name)
    type_name = type_name.to_sym
    raise "Invalid type name: #{type_name}" unless VALID_CRYSTAL_TYPES.include?(type_name)

    type_name
  end

  def cry_wasm(wasm_out = nil)
    crystal_code = @crystal_code_blocks.join("\n")
    wasm_bytes = crystal_build_wasm(crystal_code, wasm_out)
    wasm_func = create_wasm_function(wasm_bytes)

    @marked_methods.each do |name|
      define_method(name) do |*args|
        wasm_func.call(*args)
      end
    end
  end

  def crystal_build_wasm(crystal_code, wasm_out = nil)
    wasm_bytes = nil
    ENV['CRYSTAL_LIBRARY_PATH'] ||= File.expand_path('../vendor/wasm32-wasi-libs', __dir__)
    unless wasm_out
      output_file = Tempfile.create('wasm')
      wasm_out = output_file.path
    end
    Tempfile.create('crywasm') do |crystal_file|
      File.write(crystal_file.path, crystal_code)
      link_flags = '"' + @marked_methods.map { |n| "--export #{n} " }.join + '"'
      result = system(
        "crystal build #{crystal_file.path} -o #{wasm_out} --target wasm32-wasi --link-flags=#{link_flags}"
      )
      unless result
        warn 'Failed to compile Crystal code to WASM'
        warn crystal_code
        raise 'crystal build failed' unless result
      end
      wasm_bytes = IO.read(wasm_out, mode: 'rb')
    end
    output_file&.close
    wasm_bytes
  end

  def create_wasm_function(wasm_bytes)
    store = Wasmer::Store.new
    module_ = Wasmer::Module.new store, wasm_bytes

    wasi_version = Wasmer::Wasi.get_version module_, true

    wasi_env = Wasmer::Wasi::StateBuilder
               .new('wasi_test_program')
               .argument('--test')
               .environment('COLOR', 'true')
               .environment('APP_SHOULD_LOG', 'false')
               .map_directory('the_host_current_dir', '.')
               .finalize

    import_object = wasi_env.generate_import_object store, wasi_version

    instance = Wasmer::Instance.new module_, import_object
    wasm_func = instance.exports.fib
  end

  def self.extended(obj)
    obj.private_class_method\
      :cry,
      :validate_type_name,
      :validate_type_names

    # initialize class instance variables
    obj.instance_variable_set(:@crywasm_flag, false)
    obj.instance_variable_set(:@crystal_code_blocks, [])
    obj.instance_variable_set(:@marked_methods, [])
    obj.instance_variable_set(:@fname, '')
    obj.instance_variable_set(:@line_number, 0)
  end
end
