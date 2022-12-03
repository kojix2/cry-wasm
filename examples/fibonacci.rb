require 'crywasm'

class Fibonacci
  extend CryWasm

  def initialize; end

  cry [:Int32], :Int32
  def fib(n)
    if n <= 1
      1
    else
      fib(n - 1) + fib(n - 2)
    end
  end

  cry_wasm
end

(1..20).each do |i|
  puts Fibonacci.new.fib(i)
end
