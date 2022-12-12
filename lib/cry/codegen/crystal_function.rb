module Cry
  class Codegen
    class CrystalFunction
      class Declaration
        attr_accessor :name, :arg_names, :arg_types, :ret_type

        def initialize
          @arg_names = []
          @arg_types = []
        end
        
        def source
          raise 'name is not set' unless @name
          raise 'size of arg_names and arg_types are not same' unless @arg_names.size == @arg_types.size
          args = arg_names.zip(arg_types).map do |n, t|
              "#{n} : #{t}"
          end.join(', ')
          "fun #{@name}(#{args}) : #{@ret_type}"
        end
      end

      attr_accessor :declaration, :definition

      def initialize(declaration = nil, initialization = nil, definition = nil)
        @declaration = declaration
        @initialization = initialization
        @definition = definition
      end

      def source
        '' << @declaration << @initialization << @definition
      end
    end
  end
end
