require_relative 'sorcerer'

module CryWasm
  class Sexp
    def initialize(fname)
      str = IO.read(fname)
      @sexp = Ripper::SexpBuilder.new(str).parse
    end

    def extract_source_with_arguments(name, line_number)
      exp = find_method(name, line_number)
      arg_names = []
      if exp[2][0] == :paren && (exp[2][1][0] == :params)
        exp[2][1][1].each do |arg|
          arg_names << arg[1] if arg[0] == :@ident
        end
      end
      source = Sorcerer.source(exp, multiline: true, indent: true)
      [source, arg_names]
    end

    def find_method(name, line_number)
      @line_number = line_number
      name = name.to_s
      find_method2(@sexp, name)
    end

    def find_method2(arr, name)
      arr.each do |item|
        if item.is_a?(Array)
          if item[0] == :def
            return item if item[1][0] == :@ident && (item[1][1] == name) && (item[1][2][0] > @line_number)
          elsif r = find_method2(item, name)
            return r
          end
        end
      end
      nil
    end
  end
end
