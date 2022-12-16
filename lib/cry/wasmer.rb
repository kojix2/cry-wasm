require 'wasmer'

module Cry
  class Wasmer
    def initialize(wasm_bytes)
      store = ::Wasmer::Store.new
      modul = ::Wasmer::Module.new store, wasm_bytes

      wasi_version = ::Wasmer::Wasi.get_version modul, true

      wasi_env = ::Wasmer::Wasi::StateBuilder
                 .new('wasi_test_program')
                 .argument('--test')
                 .environment('COLOR', 'true')
                 .environment('APP_SHOULD_LOG', 'false')
                 .map_directory('the_host_current_dir', '.')
                 .finalize

      import_object = wasi_env.generate_import_object store, wasi_version

      @instance = ::Wasmer::Instance.new modul, import_object
    end

    def function(name)
      @instance.exports.public_send(name)
    end

    def invoke(name, *args)
      @instance.exports.public_send(name).call(*args)
    end

    def memory
      @instance.exports.memory
    end

    def write_memory(addr, t2, arg)
      uint8_view = memory.uint8_view(addr)
      arg_uint8 = case t2
                  when 'int8'   then  arg.pack('c*')
                  when 'uint8'  then  arg.pack('C*')
                  when 'int16'  then  arg.pack('s*')
                  when 'uint16' then  arg.pack('S*')
                  when 'int32'  then  arg.pack('l*')
                  when 'uint32' then  arg.pack('L*')
                  when 'int64'  then  arg.pack('q*')
                  when 'uint64' then  arg.pack('Q*')
                  else raise "unsupported type: #{t2}"
                  end.unpack('C*')
      arg.each_with_index do |_a, i|
        uint8_view[i] = arg_uint8[i]
      end
    end

    def get_view(addr, type)
      offset = case type
               when 'int8', 'uint8' then addr / 1
               when 'int16', 'uint16' then addr / 2
               when 'int32', 'uint32' then addr / 4
               # when 'int64', 'uint64' then addr / 8
               else raise "unsupported type: #{type}"
               end
      view = memory.public_send("#{type}_view", offset)
    end
  end
end

require_relative 'wasm'
Cry::Wasm.runtime = Cry::Wasmer