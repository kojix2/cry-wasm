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
  end
end
