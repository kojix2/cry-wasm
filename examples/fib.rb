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
  alias fib_ruby fib

  cry_wasm
end

print 'ruby start : '
s = Time.new
puts Fibonacci.new.fib_ruby(40)
puts "time : #{Time.new - s}"

print 'wasm start : '
s = Time.new
puts Fibonacci.new.fib(40)
puts "time: #{Time.new - s}"
