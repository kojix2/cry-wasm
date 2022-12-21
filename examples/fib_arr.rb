require 'cry/wasm'

class Sum
  extend Cry::Wasm

  cry ['Array(Int32)', 'Array(Int8)'], 'Int32'
  def run(arr1, arr2)
    arr1.sum + arr2.sum
  end

  cry_build
end

p Sum.new.run((1..100).to_a, (1..10).to_a)
