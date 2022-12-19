require 'wasmer'

module Cry
  class Wasmer
    def initialize(wasm_bytes = nil)
      load_wasm(wasm_bytes) if wasm_bytes
    end

    def load_wasm(wasm_bytes)
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
      self
    end

    def function(name)
      @instance.exports.public_send(name)
    end

    def invoke(name, *args)
      @instance.exports.public_send(name).call(*args)
    end

    def start
      invoke('_start')
    end

    def memory
      @instance.exports.memory
    end

    def write_memory(addr, t2, arg)
      uint8_view = memory.uint8_view(addr)
      arg_uint8 = case t2
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
                  end.unpack('C*')
      arg_uint8.each_with_index do |a, i|
        uint8_view[i] = a
      end
    end

    def read_memory(addr, t2, len)
      uint8_view = memory.uint8_view(addr)
      case t2
      when 'int8'    then Array.new(len * 1) { |i| uint8_view[i] }.pack('C*').unpack('c*')
      when 'uint8'   then Array.new(len * 1) { |i| uint8_view[i] }.pack('C*').unpack('C*')
      when 'int16'   then Array.new(len * 2) { |i| uint8_view[i] }.pack('C*').unpack('s*')
      when 'uint16'  then Array.new(len * 2) { |i| uint8_view[i] }.pack('C*').unpack('S*')
      when 'int32'   then Array.new(len * 4) { |i| uint8_view[i] }.pack('C*').unpack('l*')
      when 'uint32'  then Array.new(len * 4) { |i| uint8_view[i] }.pack('C*').unpack('L*')
      when 'int64'   then Array.new(len * 8) { |i| uint8_view[i] }.pack('C*').unpack('q*')
      when 'uint64'  then Array.new(len * 8) { |i| uint8_view[i] }.pack('C*').unpack('Q*')
      when 'float32' then Array.new(len * 4) { |i| uint8_view[i] }.pack('C*').unpack('e*')
      when 'float64' then Array.new(len * 8) { |i| uint8_view[i] }.pack('C*').unpack('E*')
      else raise "unsupported type: #{t2}"
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
