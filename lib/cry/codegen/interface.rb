module Cry
  class Codegen
    class Interface
      class Type < String
        # Why Symbol is not included in VALID_CRYSTAL_TYPES?
        # Because there is no way to convert String to Symbol.
        # Symbols are translated to numbers in compile time.
        # Use String instead of Symbol. See:
        # - https://github.com/crystal-lang/crystal/issues/943#issuecomment-118842665
        # - https://forum.crystal-lang.org/t/string-to-symbol
        VALID_CRYSTAL_TYPES = \
          ['Int8', 'Int8*', 'Array(Int8)',
           'UInt8',   'UInt8*',   'Array(UInt8)',
           'Int16',   'Int16*',   'Array(Int16)',
           'UInt16',  'UInt16*',  'Array(UInt16)',
           'Int32',   'Int32*',   'Array(Int32)',
           'UInt32',  'UInt32*',  'Array(UInt32)',
           'Int64',   'Int64*',   'Array(Int64)',
           'UInt64',  'UInt64*',  'Array(UInt64)',
           'Float32', 'Float32*', 'Array(Float32)',
           'Float64', 'Float64*', 'Array(Float64)',
           'String',
           'Void'].freeze

        def initialize(type_name)
          case type_name
          when String
            raise "Invalid type name: #{type_name}" unless VALID_CRYSTAL_TYPES.include?(type_name)
          when Symbol
            type_name = type_name.to_s
          else
            raise "Type name must be a String or Symbol (got #{type_name.class})"
          end

          super(type_name)
        end

        def is_pointer?
          end_with?('*')
        end

        def is_array?
          start_with?('Array(') && end_with?(')')
        end

        def inner
          if is_pointer? then delete_suffix('*')
          elsif is_array? then delete_prefix('Array(').delete_suffix(')')
          else
            self
          end
        end

        def inner_pointer
          "#{inner}*"
        end
      end

      attr_reader :name, :crystal_arg_types, :crystal_ret_type

      def initialize(name, crystal_arg_types, crystal_ret_type)
        @name = name
        @crystal_arg_types = crystal_arg_types.map { |t| Type.new(t) }
        @crystal_ret_type = Type.new(crystal_ret_type)
      end
    end
  end
end
