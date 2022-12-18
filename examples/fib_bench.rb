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
  def fib32(n)
    if n <= 2
      1
    else
      fib32(n - 1) + fib32(n - 2)
    end
  end

  cry_wasm
end

Cry::Wasm.runtime = Cry::Wasmer

class FibonacciWasmer
  extend Cry::Wasm

  cry [:Int32], :Int32
  def fib32(n)
    if n <= 2
      1
    else
      fib32(n - 1) + fib32(n - 2)
    end
  end

  cry_wasm
end

ruby = FibonacciRuby.new
wmtm = FibonacciWasmtime.new
wmer = FibonacciWasmer.new

n = (1...20).to_a

Benchmark.plot(n) do |x|
  x.report('ruby') { |i| ruby.fib(i) }
  x.report('wasmtime') { |i| wmtm.fib32(i) }
  x.report('wasmer') { |i| wmer.fib32(i) }
end

Benchmark.bm(10) do |r|
  r.report('ruby') { ruby.fib(40) }
  r.report('wasmtime') { wmtm.fib32(40) }
  r.report('wasmer') { wmer.fib32(40) }
end
