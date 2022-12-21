require 'cry/wasm'

class Fibonacci
  extend Cry::Wasm

  cry [:Int32], :Int32
  def fib(n)
    if n <= 1
      1
    else
      fib(n - 1) + fib(n - 2)
    end
  end

  def fib_rb(n)
    if n <= 1
      1
    else
      fib_rb(n - 1) + fib_rb(n - 2)
    end
  end

  cry_build
end

print 'ruby start : '
s = Time.new
puts Fibonacci.new.fib_rb(40)
puts "time : #{Time.new - s}"

print 'wasm start : '
s = Time.new
puts Fibonacci.new.fib(40)
puts "time: #{Time.new - s}"
