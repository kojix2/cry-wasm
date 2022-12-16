require 'wasmtime'

module Cry
  class Wasmtime
    def initialize(wasm_bytes)
      engine = ::Wasmtime::Engine.new
      mod = ::Wasmtime::Module.new(engine, wasm_bytes)

      linker = ::Wasmtime::Linker.new(engine, wasi: true)

      wasi_ctx = ::Wasmtime::WasiCtxBuilder
                 .new.set_stdin_string('hi!')
                 .inherit_stdout
                 .inherit_stderr
                 .set_argv(ARGV)
                 .set_env(ENV)

      store = ::Wasmtime::Store.new(engine, wasi_ctx: wasi_ctx)

      @instance = linker.instantiate(store, mod)
    end

    def function(name)
      @instance.export(name.to_s).to_func
    end

    def invoke(name, *args)
      @instance.invoke(name.to_s, *args)
    end

    def memory
      @instance.export('memory').to_memory
    end

    def hoge(addr, t2, _l, arg)
      memory.write(
        addr,
        case t2
        when 'int8'   then  arg.pack('c*')
        when 'uint8'  then  arg.pack('C*')
        when 'int16'  then  arg.pack('s*')
        when 'uint16' then  arg.pack('S*')
        when 'int32'  then  arg.pack('l*')
        when 'uint32' then  arg.pack('L*')
        when 'int64'  then  arg.pack('q*')
        when 'uint64' then  arg.pack('Q*')
        else raise "unsupported type: #{t2}"
        end
      )
    end
  end
end

module Cry
  module Wasm
    Runtime = Wasmtime
  end
end

require_relative 'wasm'
