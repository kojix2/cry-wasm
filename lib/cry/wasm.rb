require_relative 'numeric'
require_relative 'codegen'
require_relative 'compiler'
require 'tempfile'

module Cry
  autoload :Wasmer, File.expand_path('wasmer', __dir__)
  autoload :Wasmtime, File.expand_path('wasmtime', __dir__)

  # The Cry::Wasm module is for defining Ruby methods that will be compiled into WASM.
  # use `cry` to define the method signature.
  # use `cry_wasm` to compile the method to WASM.
  #
  # @example
  #  class Foo
  #    extend Cry::Wasm
  #    cry [Int32, Int32], Int32
  #    def add(a, b)
  #      a + b
  #    end
  #    cry_wasm
  #  end
  #  Foo.new.add(1, 2) #=> 3

  module Wasm
    def self.runtime=(runtime)
      @cry_wasm_runtime = runtime
    end

    def self.runtime
      @cry_wasm_runtime
    end

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

    # Defines the method signature.
    # This method must be called before the target method is defined.
    # @param arg_types [Array<String, Symbol>] crystal argument types
    # @param ret_type [String, Symbol] crystal return type
    # @return [nil]

    def cry(arg_types, ret_type)
      fname, l = caller[0].split(':')
      @cry_wasm[:codegen].source_path = fname

      # Searches for methods that appear on a line later than cry was called.
      @cry_wasm[:caller_line_number] = l.to_i
      @cry_wasm[:flag] = true
      @crystal_arg_types = arg_types
      @crystal_ret_type = ret_type

      nil
    end

    # Compile the method to WASM.
    # This method must be called after the target methods are defined.
    # @param wasm_out [String] output path of WASM
    # @param options [Hash] options for Cry::Compiler#build_wasm
    # @return [Array<Symbol>] method names that were compiled to WASM

    def cry_wasm(wasm_out = nil, **options)
      crystal_code = @cry_wasm[:codegen].crystal_code
      wasm_bytes = @cry_wasm[:compiler].build_wasm(
        crystal_code,
        export: @cry_wasm[:codegen].function_names, # There are other methods other than marked_method that must be exported.
        output: wasm_out,
        **options
      )
      runtime = @cry_wasm[:runtime].load_wasm(wasm_bytes)
      @cry_wasm[:marked_methods].each do |name|
        func = runtime.function(name)
        itfc = @cry_wasm[:codegen].interface(name)
        define_method(name) do |*args, **kwargs, &block|
          # NOTE: This is a temporary implementation.
          #       In the future, keyword arguments may be used
          #       as a specification of local variable types.
          raise ArgumentError, 'keyword arguments are not supported' unless kwargs.empty?
          raise ArgumentError, 'block is not supported' if block

          new_args = []

          itfc.crystal_arg_types.zip(args).each do |t, arg|
            if t.is_array? || t.is_pointer?
              t2 = t.inner.downcase
              l = arg.length

              addr = runtime.invoke("__alloc_buffer_#{t2}", l)
              runtime.write_memory(addr, t2, arg)

              new_args << addr
              new_args << l if t.is_array?
            elsif t == 'String'
              raise ArgumentError, "expected String, got #{arg.class}" unless arg.is_a?(String)

              arg = arg.encode('UTF-8').bytes
              l = arg.size
              addr = runtime.invoke('__alloc_buffer_uint8', l)
              runtime.write_memory(addr, 'uint8', arg)

              new_args << addr
              new_args << l
            else
              new_args << arg
            end
          end

          r = itfc.crystal_ret_type
          addr2 = nil
          if r.is_array? or r == 'String'
            addr2 = runtime.invoke('__alloc_buffer_int32', 1)
            runtime.write_memory(addr2, 'int32', [0])
            new_args << addr2
          end

          result = func.call(*new_args)

          if r.is_pointer?
            view = runtime.get_view(result, r.inner.downcase)
          elsif r.is_array?
            l2 = runtime.read_memory(addr2, 'int32', 1)[0]
            runtime.read_memory(result, r.inner.downcase, l2)
          elsif r == 'String'
            l2 = runtime.read_memory(addr2, 'int32', 1)[0]
            runtime.read_memory(result, 'uint8', l2).pack('C*').force_encoding('UTF-8')
          else
            result
          end
          # FIXME: Release memory
        end
      end
    end

    def new(...)
      super(...).tap do
        @cry_wasm[:runtime].start
      end
    end

    def self.extended(obj)
      # Initialize class instance variables
      raise "class instance variable '@cry_wasm' is already defined" if obj.instance_variable_defined?(:@cry_wasm)

      # Only one class instance variable is used here.
      # to avoid bugs caused by overwriting.
      @cry_wasm_runtime ||= Wasmer
      obj.instance_variable_set(:@cry_wasm, {
                                  runtime: @cry_wasm_runtime.new,
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
