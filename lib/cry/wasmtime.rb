require 'wasmtime'

module Cry
  class Wasmtime
    attr_reader :instance

    def initialize(wasm_bytes = nil)
      load_wasm(wasm_bytes) if wasm_bytes
    end

    def load_wasm(wasm_bytes)
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
      self
    end

    def function(name)
      instance.export(name.to_s).to_func
    end

    def invoke(name, *args)
      instance.invoke(name.to_s, *args)
    end

    def start
      invoke('_start')
    end

    def memory
      instance.export('memory').to_memory
    end

    def write_memory(addr, t2, arg)
      memory.write(
        addr,
        case t2
        when 'int8'    then arg.pack('c*')
        when 'uint8'   then arg.pack('C*')
        when 'int16'   then arg.pack('s*')
        when 'uint16'  then arg.pack('S*')
        when 'int32'   then arg.pack('l*')
        when 'uint32'  then arg.pack('L*')
        when 'int64'   then arg.pack('q*')
        when 'uint64'  then arg.pack('Q*')
        when 'float32' then arg.pack('e*')
        when 'float64' then arg.pack('E*')
        else raise "unsupported type: #{t2}"
        end
      )
    end

    def get_view(_addr, _type)
      raise 'not implemented'
    end

    def read_memory(addr, t2, len)
      case t2
      when 'int8'    then memory.read(addr, len * 1).unpack('c*')
      when 'uint8'   then memory.read(addr, len * 1).unpack('C*')
      when 'int16'   then memory.read(addr, len * 2).unpack('s*')
      when 'uint16'  then memory.read(addr, len * 2).unpack('S*')
      when 'int32'   then memory.read(addr, len * 4).unpack('l*')
      when 'uint32'  then memory.read(addr, len * 4).unpack('L*')
      when 'int64'   then memory.read(addr, len * 8).unpack('q*')
      when 'uint64'  then memory.read(addr, len * 8).unpack('Q*')
      when 'float32' then memory.read(addr, len * 4).unpack('e*')
      when 'float64' then memory.read(addr, len * 8).unpack('E*')
      else raise "unsupported type: #{t2}"
      end
    end
  end
end

require_relative 'wasm'
Cry::Wasm.runtime = Cry::Wasmtime
