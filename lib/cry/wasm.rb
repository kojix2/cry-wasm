require_relative 'numeric'
require_relative 'codegen'
require_relative 'compiler'
require 'tempfile'

module Cry
  module Wasm
    require_relative 'wasmer'
    # require_relative 'wasmtime'
    Runtime = Wasmer

    def method_added(name)
      return super(name) unless @cry_wasm[:flag]

      @cry_wasm[:codegen].add_crystal_function(
        name,
        @crystal_arg_types,
        @crystal_ret_type,
        @cry_wasm[:caller_line_number]
      )

      @cry_wasm[:marked_methods] << name
      @cry_wasm[:caller_line_number] = 0
      @cry_wasm[:flag] = false

      super(name)
    end

    def cry(arg_types, ret_type)
      fname, l = caller[0].split(':')
      @cry_wasm[:codegen].source_path = fname

      # Searches for methods that appear on a line later than cry was called.
      @cry_wasm[:caller_line_number] = l.to_i
      @cry_wasm[:flag] = true
      @crystal_arg_types = arg_types
      @crystal_ret_type = ret_type
    end

    def cry_wasm(wasm_out = nil, **options)
      crystal_code = @cry_wasm[:codegen].crystal_code
      wasm_bytes = @cry_wasm[:compiler].build_wasm(
        crystal_code,
        export: @cry_wasm[:codegen].function_names, # There are other methods other than marked_method that must be exported.
        output: wasm_out,
        **options
      )
      runtime = Runtime.new(wasm_bytes)
      @cry_wasm[:marked_methods].each do |name|
        func = runtime.function(name)
        define_method(name) do |*args|
          func.call(*args)
        end
      end
    end

    def self.extended(obj)
      obj.private_class_method\
        :validate_type_name,
        :validate_type_names

      # Initialize class instance variables
      raise "class instance variable '@cry_wasm' is already defined" if obj.instance_variable_defined?(:@cry_wasm)

      # Only one class instance variable is used here.
      # to avoid bugs caused by overwriting.
      obj.instance_variable_set(:@cry_wasm, {
                                  flag: false,
                                  marked_methods: [],
                                  fname: '',
                                  line_number: 0,
                                  compiler: Compiler.new,
                                  codegen: Codegen.new
                                })
    end
  end
end
