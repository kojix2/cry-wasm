require 'cry/wasm'

class Fibonacci
  extend Cry::Wasm
  using Cry::Numeric

  cry [:Int8], :Int8
  def fib8(n)
    if n <= 1
      1.to_i8
    else
      fib8(n - 1) + fib8(n - 2)
    end
  end

  cry [:Int16], :Int16
  def fib16(n)
    if n <= 1
      1.to_i16
    else
      fib16(n - 1) + fib16(n - 2)
    end
  end

  cry [:Int32], :Int32
  def fib32(n)
    if n <= 1
      1
    else
      fib32(n - 1) + fib32(n - 2)
    end
  end

  cry %i[Int64], :Int64
  def fib64(n)
    if n <= 1
      1.to_i64
    else
      fib64(n - 1) + fib64(n - 2)
    end
  end

  cry %i[Int32], :Int64
  def fib(i)
    case i
    when 0..10
      fib8(i.to_i8)
    when 11..22
      fib16(i.to_i16)
    when 23..45
      fib32(i.to_i32)
    when 46..50
      fib64(i.to_i64)
    end.not_nil!.to_i64
  end

  cry_wasm
end

a = Fibonacci.new

48.times do |i|
  print (i + 1).to_s.rjust(2)
  puts a.fib(i).to_s.rjust(12)
end
