require 'cry/wasm'

class Hello
  extend Cry::Wasm

  cry_eval(<<~CODE)
    class CRYSTAL
      def initialize
        @msg = "Hello, WASM World!"
      end
      def world
        puts @msg
      end
    end
  CODE

  cry [], :Void
  def world
    CRYSTAL.new.world
  end

  cry_build
end

Hello.new.world
