require 'tempfile'
require 'wasmer'
require_relative 'crywasm/sorcerer'

module CryWasm
  def method_added(name)
    return super(name) unless @crywasm_flag

    fun = find_method_in_s_expression(@s_expression, name.to_s)
    arg_names = []
    if fun[2][0] == :paren && (fun[2][1][0] == :params)
      fun[2][1][1].each do |arg|
        arg_names << arg[1] if arg[0] == :@ident
      end
    end
    code = Sorcerer.source(fun, multiline: true, indent: true)
    hoge = arg_names.zip(@crystal_arg_types).map { |n, t| "#{n} : #{t}" }.join(', ')
    dec = "fun #{name}(#{hoge}) : #{@crystal_arg_type}\n"
    @method_names << name
    @crystal_code_blocks << code.lines[1..-1].unshift(dec).join
    @crywasm_flag = false

    super(name)
  end

  def find_method_in_s_expression(arr, n)
    arr.each_with_index do |item, _index|
      if item.is_a?(Array)
        if item[0] == :def
          return item if item[1][0] == :@ident && (item[1][1] == n) && (item[1][2][0] > @line_number)
        elsif r = find_method_in_s_expression(item, n)
          return r
        end
      end
    end
    nil
  end

  def cry(arg_types, ret_type)
    @crystal_code_blocks ||= []
    @method_names ||= []
    f, l = caller[0].split(':')
    @line_number = l.to_i
    @s_expression = Ripper::SexpBuilder.new(IO.read(f)).parse
    @crywasm_flag = true
    @crystal_arg_types = check_arg_types(arg_types)
    @crystal_arg_type = check_ret_type(ret_type)
  end

  def check_arg_types(arg_types)
    arg_types
  end

  def check_ret_type(ret_type)
    ret_type
  end

  def cry_wasm(wasm_out = nil)
    crystal_code = @crystal_code_blocks.join("\n")
    wasm_bytes = crystal_build_wasm(crystal_code, wasm_out)
    wasm_func = create_wasm_function(wasm_bytes)

    @method_names.each do |name|
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
      link_flags = '"' + @method_names.map { |n| "--export #{n} " }.join + '"'
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
    output_file.close if output_file
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

  def stash_method_name(name)
    "_#{name}_raw"
  end

  def self.extended(obj)
    obj.private_class_method\
      :cry,
      :check_arg_types,
      :check_ret_type
  end
end
