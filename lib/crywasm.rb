# frozen_string_literal: true

require 'tempfile'
require 'wasmer'
require_relative 'crywasm/sorcerer'

module CryWasm
  class MySexp
    def initialize(str)
      @sexp = Ripper::SexpBuilder.new(str).parse
    end

    def extract_source_with_arguments(name, line_number)
      exp = find_method(name, line_number)
      arg_names = []
      if exp[2][0] == :paren && (exp[2][1][0] == :params)
        exp[2][1][1].each do |arg|
          arg_names << arg[1] if arg[0] == :@ident
        end
      end
      source = Sorcerer.source(exp, multiline: true, indent: true)
      [source, arg_names]
    end

    def find_method(name, line_number)
      @line_number = line_number
      name = name.to_s
      find_method2(@sexp, name)
    end

    def find_method2(arr, name)
      arr.each do |item|
        if item.is_a?(Array)
          if item[0] == :def
            return item if item[1][0] == :@ident && (item[1][1] == name) && (item[1][2][0] > @line_number)
          elsif r = find_method2(item, name)
            return r
          end
        end
      end
      nil
    end
  end

  def method_added(name)
    return super(name) unless @crywasm_flag

    ruby_code_block, arg_names = @s_expression.extract_source_with_arguments(name, @line_number)
    crystal_args = arg_names.zip(@crystal_arg_types).map { |n, t| "#{n} : #{t}" }.join(', ')
    crystal_define_fun = "fun #{name}(#{crystal_args}) : #{@crystal_arg_type}\n"
    crystal_code_block = ruby_code_block.lines[1..].unshift(crystal_define_fun).join
    @crystal_code_blocks << crystal_code_block

    @marked_methods << name
    @crywasm_flag = false

    super(name)
  end

  def cry(arg_types, ret_type)
    @crystal_code_blocks ||= []
    @marked_methods ||= []
    f, l = caller[0].split(':')
    @line_number = l.to_i
    @s_expression = MySexp.new(IO.read(f))
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
