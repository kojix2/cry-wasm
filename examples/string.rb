require 'cry/wasm'

class Say
  extend Cry::Wasm

  cry %w[String String String], :String
  def hello(hello, lang, world)
    "#{hello}, #{lang} #{world}!"
  end

  cry_build
end

puts Say.new.hello('hola', 'クリスタル', 'World') # UTF-8
