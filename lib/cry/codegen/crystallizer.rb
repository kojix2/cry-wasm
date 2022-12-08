module Cry
  class Codegen
    class Crystallizer
      attr_accessor :ruby_method, :crystal_arg_types, :crystal_ret_type

      def initialize(ruby_method, crystal_arg_types, crystal_ret_type)
        @ruby_method = ruby_method
        @crystal_arg_types = crystal_arg_types
        @crystal_ret_type = crystal_ret_type
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
    end
  end
end
