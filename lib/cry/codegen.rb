require 'sorcerer'
require_relative 'codegen/ruby_method'
require_relative 'codegen/crystal_function'
require_relative 'codegen/crystallizer'

module Cry
  class Codegen
    attr_accessor :sexp

    def initialize(fname)
      str = IO.read(fname)
      @sexp = Ripper::SexpBuilder.new(str).parse
    end

    def crystalize(name, crystal_arg_types, crystal_ret_type, line_number)
      ruby_method = extract_ruby_method(name, line_number)
      c = Crystallizer.new(ruby_method, crystal_arg_types, crystal_ret_type)
      cry_func = c.source
    end

    def extract_ruby_method(name, line_number)
      exp = find_ruby_method(name, line_number)
      RubyMethod.new_from_sexp(name, exp)
    end

    def find_ruby_method(name, line_number)
      @line_number = line_number
      name = name.to_s
      find_ruby_method2(@sexp, name)
    end

    def find_ruby_method2(arr, name)
      arr.each do |item|
        if item.is_a?(Array)
          if item[0] == :def
            return item if item[1][0] == :@ident && (item[1][1] == name) && (item[1][2][0] > @line_number)
          elsif r = find_ruby_method2(item, name)
            return r
          end
        end
      end
      nil
    end
  end
end
