require 'cry/wasm'

class Fibonacci
  extend Cry::Wasm

  def initialize; end

  cry ['UInt32'], 'UInt32*'
  def fib(n)
    m = Pointer(UInt32).malloc(n + 2)
    m[0] = 1
    m[1] = 1
    n.times do |i|
      m[i + 2] = m[i] + m[i + 1]
    end
    m
  end

  cry_wasm
end

v = Fibonacci.new.fib(45)
47.times do |i|
  puts v[i]
end
