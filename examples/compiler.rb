require 'cry/wasm'

compiler = Cry::Compiler.new
wasm_bytes = compiler.build_wasm <<~CRYSTAL
  class Hello
    def initialize
      @message = "Hello, Crystal WASM World!"
      @info = [Crystal::DESCRIPTION,
               Crystal::LIBRARY_PATH,
               Crystal::PATH,
               Crystal::VERSION].join("\n")
    end

    def hi
      puts @message, @info
    end
  end

  Hello.new.hi
CRYSTAL

Cry::Wasmer.new(wasm_bytes).start
