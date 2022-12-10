module Cry
  class Codegen
    class Crystallizer
      VALID_CRYSTAL_TYPES = %i[Int8 UInt8 Int16 UInt16 Int32 UInt32 Int64 UInt64 Float32 Float64].freeze

      attr_accessor :ruby_method, :crystal_arg_types, :crystal_ret_type

      def initialize(ruby_method, interface)
        @ruby_method = ruby_method
        @crystal_arg_types = validate_type_names(interface.crystal_arg_types)
        @crystal_ret_type = validate_type_name(interface.crystal_ret_type)
      end

      def crystallize
        declaration = function_declaration(ruby_method, crystal_arg_types, crystal_ret_type)
        definition = function_definition(ruby_method)
        CrystalFunction.new(declaration, definition)
      end

      def function_declaration(ruby_method, crystal_arg_types, crystal_ret_type)
        crystal_args = ruby_method.arg_names
                                  .zip(crystal_arg_types)
                                  .map { |n, t| "#{n} : #{t}" }
                                  .join(', ')
        "fun #{ruby_method.name}(#{crystal_args}) : #{crystal_ret_type}\n"
      end

      def function_definition(ruby_method)
        # FIXME
        ruby_method.source.lines[1..].join
      end

      def source
        crystallize.source
      end

      def validate_type_names(type_names)
        type_names.map { |t| validate_type_name(t) }
      end

      def validate_type_name(type_name)
        type_name = type_name.to_sym
        raise "Invalid type name: #{type_name}" unless VALID_CRYSTAL_TYPES.include?(type_name)

        type_name
      end
    end
  end
end
