module Cry
  class Codegen
    class CrystalFunction
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
