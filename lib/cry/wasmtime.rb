require 'wasmtime'

module Cry
  class Wasmtime
    def initialize(wasm_bytes)
      engine = ::Wasmtime::Engine.new
      mod = ::Wasmtime::Module.new(engine, wasm_bytes)

      linker = ::Wasmtime::Linker.new(engine, wasi: true)

      wasi_ctx = ::Wasmtime::WasiCtxBuilder.new
                                           .set_stdin_string('hi!')
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
  end
end
