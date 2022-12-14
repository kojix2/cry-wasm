require 'cry/wasm'

class Fibonacci
  extend Cry::Wasm

  def initialize; end

  cry ['UInt32'], 'Array(UInt32)'
  def fib(n)
    m = Array(UInt32).new(n + 1)
    n > 0 && (m[0] = 1)
    n > 1 && (m[1] = 1)
    n > 2 && (n - 2).times { |i| m[i + 2] = m[i] + m[i + 1] }
    m
  end

  cry_wasm
end

result = Fibonacci.new.fib(47)
47.times do |i|
  print i + 1
  puts result[i].to_s.rjust(12)
end