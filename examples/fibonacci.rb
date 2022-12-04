require 'cry_wasm'

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

  cry %i[Int64 Int64], :Int64
  def fib64(n, i)
    if n <= 1
      i
    else
      fib64(n - 1, i) + fib64(n - 2, i)
    end
  end

  cry_wasm
end

a = Fibonacci.new

(1..20).each do |i|
  puts a.fib(i)
end

(1..46).each do |i|
  puts a.fib64(i, 1)
end
