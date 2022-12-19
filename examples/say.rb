require 'cry/wasm'

class Say
  extend Cry::Wasm

  cry [], :Void
  def hello
    puts 'Hello, Crystal World!'
  end

  cry_wasm
end

Say.new.hello
