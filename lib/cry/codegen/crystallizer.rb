module Cry
  class Codegen
    class Crystallizer
      VALID_CRYSTAL_TYPES = \
        %w[Int8 UInt8 Int16 UInt16 Int32 UInt32 Int64 UInt64 Float32 Float64].flat_map do |t|
          [t, "#{t}*", "Array(#{t})"]
        end.freeze

      attr_accessor :ruby_method, :crystal_arg_types, :crystal_ret_type

      def initialize(ruby_method, interface)
        @ruby_method = ruby_method
        @crystal_arg_types = validate_type_names(interface.crystal_arg_types)
        @crystal_ret_type = validate_type_name(interface.crystal_ret_type)
      end

      def crystallize
        declaration, initialization = function_declaration(ruby_method, crystal_arg_types, crystal_ret_type)
        definition = function_definition(ruby_method)
        [CrystalFunction.new(declaration, initialization, definition)]
      end

      def function_declaration(ruby_method, crystal_arg_types, crystal_ret_type)
        init = []
        crystal_args = ruby_method.arg_names.zip(crystal_arg_types).map do |n, t|
          if t =~ /Array\((.*)\)/
            init << "  #{n} = #{t}.new(__#{n}_len_){|i| __#{n}_ptr_[i]}" # better copy ?
            "__#{n}_ptr_ : #{::Regexp.last_match(1)}*, __#{n}_len_ : Int32"
          else
            "#{n} : #{t}"
          end
        end
        crystal_args << '__return_len_ : Int32*' if crystal_ret_type.is_array?

        ret_type = if crystal_ret_type.is_array?
                     crystal_ret_type.inner_pointer
                   else
                     crystal_ret_type
                   end
        declaration = "fun #{ruby_method.name}(#{crystal_args.join(', ')}) : #{ret_type}"
        initialization = init.join("\n")
        [declaration, initialization]
      end

      def function_definition(ruby_method)
        # FIXME
        ruby_method.source.lines[1..].join
      end

      def source
        crystallize.map(&:source).join("\n\n")
      end

      def validate_type_names(type_names)
        type_names.map { |t| validate_type_name(t) }
      end

      def validate_type_name(type_name)
        type_name = type_name.to_s
        raise "Invalid type name: #{type_name}" unless VALID_CRYSTAL_TYPES.include?(type_name)

        type_name
      end
    end
  end
end
