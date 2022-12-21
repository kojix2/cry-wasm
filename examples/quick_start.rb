require 'cry/wasm'

class Fibonacci
  extend Cry::Wasm            # (1) Extend your class

  cry [:Int32], :Int32        # (2) Write type signatures
  def fib(n)
    return 1 if n <= 2

    fib(n - 1) + fib(n - 2)
  end

  cry_build                    # (3) Compile Wasm
end

p Fibonacci.new.fib(40)       # (4) Call Wasm Function
