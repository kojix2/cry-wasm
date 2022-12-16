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

    def hoge(addr, t2, l, arg)
      view = get_view(addr, t2)
      memory_grow(view, l)
      l.times { |j| view[j] = arg[j] }
    end

    def get_view(addr, type)
      offset = get_offset(addr, type)
      view = memory.public_send("#{type}_view", offset)
    end

    private

    # FIXME
    def memory_grow(view, l)
      loop do
        flag = false
        begin
          view[l]
          flag = true
        rescue IndexError
          memory.grow(1)
        end
        break if flag
      end
    end

    def get_offset(addr, t)
      case t
      when 'int8', 'uint8' then addr / 1
      when 'int16', 'uint16' then addr / 2
      when 'int32', 'uint32' then addr / 4
      # when 'int64', 'uint64' then addr / 8
      else raise "unsupported type: #{t}"
      end
    end
  end
end

module Cry
  module Wasm
    Runtime = Wasmer
  end
end

require_relative 'wasm'
