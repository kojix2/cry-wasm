require 'spec_helper'

def example(name)
  load File.expand_path("../examples/#{name}.rb", __dir__), true
end

FIBONACCI47 = <<~FIBONACCI
   1           1
   2           1
   3           2
   4           3
   5           5
   6           8
   7          13
   8          21
   9          34
  10          55
  11          89
  12         144
  13         233
  14         377
  15         610
  16         987
  17        1597
  18        2584
  19        4181
  20        6765
  21       10946
  22       17711
  23       28657
  24       46368
  25       75025
  26      121393
  27      196418
  28      317811
  29      514229
  30      832040
  31     1346269
  32     2178309
  33     3524578
  34     5702887
  35     9227465
  36    14930352
  37    24157817
  38    39088169
  39    63245986
  40   102334155
  41   165580141
  42   267914296
  43   433494437
  44   701408733
  45  1134903170
  46  1836311903
  47  2971215073
FIBONACCI

RSpec.describe 'Examples' do
  it 'fib_simple' do
    expect { example('fib_simple') }.to output(/wasm start : 165580141/).to_stdout
  end

  it 'fib_type' do
    expect { example('fib_types') }.to output(FIBONACCI47 + "48  4807526976\n").to_stdout
  end

  it 'fib_arr_ptr' do
    expect { example('fib_arr_ptr') }.to output("5050\n").to_stdout
  end

  it 'fib_arr' do
    expect { example('fib_arr') }.to output("5105\n").to_stdout
  end

  it 'fib_cheat' do
    expect { example('fib_cheat') }.to output(FIBONACCI47).to_stdout
  end

  it 'string' do
    expect { example('string') }.to output("hola, クリスタル World!\n").to_stdout
  end
end
