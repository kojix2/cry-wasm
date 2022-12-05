require 'cry/wasm'

class Fibonacci
  extend Cry::Wasm
  using Cry::Numeric

  def initialize; end

  cry [:Int32], :Int32
  def fib(n)
    if n <= 1
      1
    else
      fib(n - 1) + fib(n - 2)
    end
  end

  cry %i[Int64], :Int64
  def fib64(n)
    if n <= 1
      1.to_i64
    else
      fib64(n - 1) + fib64(n - 2)
    end
  end

  cry_wasm
end

a = Fibonacci.new

(1..45).each do |i|
  puts "#{i} #{a.fib(i)}"
end

puts "#{46} #{a.fib64(46)}"
