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
              ptr = Pointer(#{crystal_ret_type.inner}).malloc(l)
              l.times {|i| ptr[i] = #{crystal_ret_type.inner}.new(__return_array_[i])}
              ptr
            end
          CODE
        else
          definition = function_definition(ruby_method)
        end
        funcs << CrystalFunction.new(declaration, initialization, definition)
        funcs
      end

      def function_declaration(ruby_method, crystal_arg_types, crystal_ret_type)
        init = []
        d = CrystalFunction::Declaration.new
        d.name = ruby_method.name
        ruby_method.arg_names.zip(crystal_arg_types).each do |n, t|
          if t =~ /Array\((.*)\)/
            init << "  #{n} = #{t}.new(__#{n}_len_){|i| __#{n}_ptr_[i]}" # better copy ?
            d.arg_names << "__#{n}_ptr_"
            d.arg_types << "#{::Regexp.last_match(1)}*"
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
        end

        d.ret_type = crystal_ret_type.is_array? ? crystal_ret_type.inner_pointer : crystal_ret_type
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
