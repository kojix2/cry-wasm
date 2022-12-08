require 'cry/wasm'
require 'benchmark/plot'

class Fibonacci
  extend Cry::Wasm

  cry [:Int32], :Int32
  def fib32(n)
    if n <= 1
      1
    else
      fib32(n - 1) + fib32(n - 2)
    end
  end

  def fib_ruby(n)
    if n <= 1
      1
    else
      fib_ruby(n - 1) + fib_ruby(n - 2)
    end
  end

  cry_wasm
end

a = Fibonacci.new
n = (0...20).to_a

Benchmark.plot(n) do |x|
  x.report('fib_ruby') do |i|
    a.fib_ruby(i)
  end

  x.report('fib_wasm') do |i|
    a.fib32(i)
  end
end

Benchmark.bm(10) do |r|
  r.report 'fib_ruby(40)' do
    a.fib_ruby(40)
  end
  r.report 'fib_wasm(40)' do
    a.fib32(40)
  end
end
