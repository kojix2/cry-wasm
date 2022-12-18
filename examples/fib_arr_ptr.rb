require 'cry/wasm'

class Sum
  extend Cry::Wasm

  cry ['Int32*', 'Int32'], 'Int32'
  def run(arr, l)
    s = 0
    l.times do |i|
      s += arr[i]
    end
    s
  end

  cry_wasm
end

p Sum.new.run((1..100).to_a, 100)
