require_relative 'numeric'
require_relative 'codegen'
require_relative 'compiler'
require 'tempfile'

module Cry
  module Wasm
    require_relative 'wasmer'
    # require_relative 'wasmtime'
    Runtime = Wasmer

    VALID_CRYSTAL_TYPES = %i[Int8 UInt8 Int16 UInt16 Int32 UInt32 Int64 UInt64 Float32 Float64].freeze

    def method_added(name)
      return super(name) unless @cry_wasm[:flag]

      crystal_code_block = @codegen.crystalize(
        name,
        @crystal_arg_types,
        @crystal_ret_type,
        @cry_wasm[:caller_line_number]
      )

      @cry_wasm[:crystal_code_blocks] << crystal_code_block

      @cry_wasm[:marked_methods] << name
      @cry_wasm[:caller_line_number] = 0
      @cry_wasm[:flag] = false

      super(name)
    end

    def cry(arg_types, ret_type)
      fname, l = caller[0].split(':')
      # In most cases, previously parsed S-expressions can be reused.
      if fname != @cry_wasm[:source_file_name]
        @codegen = Codegen.new(fname)
        @cry_wasm[:source_file_name] = fname
      end
      # Searches for methods that appear on a line later than cry was called.
      @cry_wasm[:caller_line_number] = l.to_i
      @cry_wasm[:flag] = true
      @crystal_arg_types = validate_type_names(arg_types)
      @crystal_ret_type = validate_type_name(ret_type)
    end

    def validate_type_names(type_names)
      type_names.map { |t| validate_type_name(t) }
    end

    def validate_type_name(type_name)
      type_name = type_name.to_sym
      raise "Invalid type name: #{type_name}" unless VALID_CRYSTAL_TYPES.include?(type_name)

      type_name
    end

    def cry_wasm(wasm_out = nil, **options)
      crystal_code = @cry_wasm[:crystal_code_blocks].join("\n")
      wasm_bytes = @cry_wasm[:compiler].build_wasm(
        crystal_code,
        export: @cry_wasm[:marked_methods],
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
                                  crystal_code_blocks: [],
                                  marked_methods: [],
                                  fname: '',
                                  line_number: 0,
                                  compiler: Compiler.new
                                })
    end
  end
end
