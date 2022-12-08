module Cry
  class Codegen
    class CrystalFunction
      attr_accessor :declaration, :definition

      def initialize(declaration = nil, definition = nil)
        @declaration = declaration
        @definition = definition
      end

      def source
        @declaration + @definition
      end
    end
  end
end
