# frozen_string_literal: true

module Cry
  class Codegen
    class Crystallizer
      attr_accessor :ruby_method, :crystal_arg_types, :crystal_ret_type

      def initialize(ruby_method, interface)
        @ruby_method = ruby_method
        @crystal_arg_types = interface.crystal_arg_types
        @crystal_ret_type = interface.crystal_ret_type
      end

      def crystallize
        funcs = []
        declaration, initialization = function_declaration(ruby_method, crystal_arg_types, crystal_ret_type)
        if crystal_ret_type.is_array?
          initialization << "\n__return_array_=("
          definition = function_definition(ruby_method)
          definition = definition.delete_suffix("end\n")
          definition << <<~CODE
              )
              l = __return_array_.size.to_i32
              __return_len_[0] = l
              __return_array_.to_unsafe
            end
          CODE
        elsif crystal_ret_type == 'String'
          initialization << "\n__return_str_=("
          definition = function_definition(ruby_method)
          definition = definition.delete_suffix("end\n")
          definition << <<~CODE
              )
              l = __return_str_.bytesize
              __return_len_[0] = l
              __return_str_.bytes.to_unsafe
            end
          CODE
        else
          definition = function_definition(ruby_method)
        end
        funcs << CrystalFunction.new(declaration, initialization, definition)
        funcs
      end

      def function_declaration(ruby_method, crystal_arg_types, crystal_ret_type)
        if ruby_method.arg_names.size != crystal_arg_types.size
          raise "The number of arguments of #{ruby_method.name} is different: #{ruby_method.arg_names.size} != #{crystal_arg_types.size}"
        end

        init = []
        d = CrystalFunction::Declaration.new
        d.name = ruby_method.name
        ruby_method.arg_names.zip(crystal_arg_types).each do |n, t|
          case t
          when /Array\((.*)\)/
            init << "  #{n} = #{t}.new(__#{n}_len_){|i| __#{n}_ptr_[i]}" # better copy ?
            d.arg_names << "__#{n}_ptr_"
            d.arg_types << "#{::Regexp.last_match(1)}*"
            d.arg_names << "__#{n}_len_"
            d.arg_types << 'Int32'
          when 'String'
            init << "  #{n} = String.new(__#{n}_ptr_, __#{n}_len_)"
            d.arg_names << "__#{n}_ptr_"
            d.arg_types << 'UInt8*'
            d.arg_names << "__#{n}_len_"
            d.arg_types << 'Int32'
          else
            d.arg_names << n
            d.arg_types << t
          end
        end

        if crystal_ret_type.is_array?
          d.arg_names << '__return_len_'
          d.arg_types << 'Int32*'
          d.ret_type = crystal_ret_type.inner_pointer
        elsif crystal_ret_type == 'String'
          d.arg_names << '__return_len_'
          d.arg_types << 'Int32*'
          d.ret_type = 'UInt8*'
        else
          d.ret_type = crystal_ret_type
        end

        initialization = init.join("\n")
        [d.source, initialization]
      end

      def function_definition(ruby_method)
        # FIXME
        ruby_method.source.lines[1..].join
      end

      def source
        crystallize.map(&:source).join("\n\n")
      end
    end
  end
end
