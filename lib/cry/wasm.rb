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
        itfc = @cry_wasm[:codegen].interface(name)
        define_method(name) do |*args, **kwargs, &block|
          # NOTE: This is a temporary implementation.
          #       In the future, keyword arguments may be used
          #       as a specification of local variable types.
          raise ArgumentError, 'keyword arguments are not supported' unless kwargs.empty?
          raise ArgumentError, 'block is not supported' if block

          new_args = []

          itfc.crystal_arg_types.each_with_index do |t, i|
            unless t.include?('*') or t.include?('Array')
              new_args << args[i]
              next
            end

            if t.to_s.include?('*') # Pointer
              t2 = t.sub('*', '').downcase
              l = args[i].length
            else
              t.to_s.include?('Array')
              t2 = t.sub('Array(', '')[0..-2].downcase
              l = args[i].length
            end

            addr = runtime.invoke("__alloc_buffer_#{t2}", l)
            # FIXME: support wasmer-ruby only
            offset = case t2
                     when 'int8', 'uint8' then addr / 1
                     when 'int16', 'uint16' then addr / 2
                     when 'int32', 'uint32' then addr / 4
                     # when 'int64', 'uint64' then addr / 8
                     else raise "unsupported type: #{t2}"
                     end
            view = runtime.memory.public_send("#{t2}_view", offset)
            # FIXME: memory size
            loop do
              flag = false
              begin
                view[l]
                flag = true
              rescue IndexError
                runtime.memory.grow(1)
              end
              break if flag
            end
            l.times { |j| view[j] = args[i][j] }
            new_args << addr
            new_args << l if t.to_s.include?('Array')
          end
          result = func.call(*new_args)
          # FIXME: support return type as pointer
          # FIXME: Release memory
        end
      end
    end

    def self.extended(obj)
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
