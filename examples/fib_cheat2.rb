require 'cry/wasm'

class Fibonacci
  extend Cry::Wasm

  def initialize; end

  cry ['Int32'], 'Array(Int32)'
  def fib(n)
    __return_len_[0] = n
    m = Pointer(Int32).malloc(n)
    n.times {|i| m[i] = i}
    m
  end

  cry_wasm
end

view = Fibonacci.new.fib(47)
47.times do |i|
  print i + 1
  puts view[i].to_s.rjust(12)
end
