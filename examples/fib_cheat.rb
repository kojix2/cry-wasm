require 'cry/wasm'

class Fibonacci
  extend Cry::Wasm

  cry ['UInt32'], 'UInt32*'
  def fib(n)
    m = Pointer(UInt32).malloc(n + 2)
    n > 0 && (m[0] = 1)
    n > 1 && (m[1] = 1)
    n > 2 && (n - 2).times { |i| m[i + 2] = m[i] + m[i + 1] }
    m
  end

  cry_build
end

view = Fibonacci.new.fib(47)
47.times do |i|
  print (i + 1).to_s.rjust(2)
  puts view[i].to_s.rjust(12)
end
