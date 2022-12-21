require 'cry/wasm'
require 'cry/wasmtime'
require 'cry/wasmer'
require 'benchmark/plot'

class FibonacciRuby
  def fib(n)
    if n <= 2
      1
    else
      fib(n - 1) + fib(n - 2)
    end
  end
end

Cry::Wasm.runtime = Cry::Wasmtime

class FibonacciWasmtime
  extend Cry::Wasm

  cry [:Int32], :Int32
  def fib(n)
    if n <= 2
      1
    else
      fib(n - 1) + fib(n - 2)
    end
  end

  cry_build
end

Cry::Wasm.runtime = Cry::Wasmer

class FibonacciWasmer
  extend Cry::Wasm

  cry [:Int32], :Int32
  def fib(n)
    if n <= 2
      1
    else
      fib(n - 1) + fib(n - 2)
    end
  end

  cry_build
end

ruby = FibonacciRuby.new
wmtm = FibonacciWasmtime.new
wmer = FibonacciWasmer.new
n = (1..20).to_a

Benchmark.bmbm(16) do |r|
  r.report('ruby     fib(40)') { ruby.fib(40) }
  r.report('wasmtime fib(40)') { wmtm.fib(40) }
  r.report('wasmer   fib(40)') { wmer.fib(40) }
end

Benchmark.plot(n) do |x|
  # wasmer and wasmtime are slower on the first one or two calls
  # If you want to reduce the impact of the first call, uncomment the following lines
  # ruby.fib(0)
  # wmtm.fib(0)
  # wmer.fib(0)
  x.report('ruby') { |i| ruby.fib(i) }
  x.report('wasmtime') { |i| wmtm.fib(i) }
  x.report('wasmer') { |i| wmer.fib(i) }
end
