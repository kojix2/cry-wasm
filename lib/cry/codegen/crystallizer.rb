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
        if crystal_ret_type.is_array?
          declaration, _init = function_declaration(ruby_method, crystal_arg_types, crystal_ret_type)
          definition = function_definition_wrapper(ruby_method, crystal_arg_types, crystal_ret_type)
          funcs << CrystalFunction.new(declaration, '', definition)
          declaration, initialization = function_declaration_wrapper(ruby_method, crystal_arg_types, crystal_ret_type)
          definition = function_definition(ruby_method)
          funcs << CrystalFunction.new(declaration, initialization, definition)
        else
          declaration, initialization = function_declaration(ruby_method, crystal_arg_types, crystal_ret_type)
          definition = function_definition(ruby_method)
          funcs << CrystalFunction.new(declaration, initialization, definition)
        end
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

      def function_declaration_wrapper(ruby_method, crystal_arg_types, crystal_ret_type)
        init = []
        d = CrystalFunction::Declaration.new(decl: 'def')
        d.name = "__#{ruby_method.name}_"

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
        d.ret_type = crystal_ret_type

        initialization = init.join("\n")
        [d.source, initialization]
      end

      def function_definition(ruby_method)
        # FIXME
        ruby_method.source.lines[1..].join
      end

      def function_definition_wrapper(ruby_method, _crystal_arg_types, crystal_ret_type)
        # FIXME
        code = <<~CODE
            v = __#{ruby_method.name}_(#{ruby_method.arg_names.join(', ')})
            __return_len_[0] = v.size
            m = Pointer(#{crystal_ret_type.inner}).malloc(v.size)
            v.size.times do |i|
              m[i] = #{crystal_ret_type.inner}.new(v[i])
            end
            m
          end
        CODE
      end

      def source
        crystallize.map(&:source).join("\n\n")
      end
    end
  end
end
