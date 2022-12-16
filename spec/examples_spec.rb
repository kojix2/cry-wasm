require 'spec_helper'

def example(name)
  load File.expand_path("../examples/#{name}.rb", __dir__), Module.new
end

RSpec.describe 'Examples' do

  it 'fib_simple' do
    expect {example("fib_simple")}.to output(/wasm start : 165580141/).to_stdout
  end

  it 'fib_type' do
    expect {example("fib_types")}.to output(/48  4807526976/).to_stdout
  end

  it 'fib_arr_ptr' do
    expect {example("fib_arr_ptr")}.to output("5050\n").to_stdout
  end
  
  it 'fib_arr' do
    expect {example("fib_arr")}.to output("5105\n").to_stdout
  end
end
