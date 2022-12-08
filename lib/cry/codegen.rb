require 'sorcerer'

module Cry
  class Codegen
    attr_accessor :sexp

    def initialize(fname)
      str = IO.read(fname)
      @sexp = Ripper::SexpBuilder.new(str).parse
    end

    def crystalize(name, crystal_arg_types, crystal_ret_type, line_number)
      ruby_code_block, arg_names = extract_ruby_method(name, line_number)
      declaration = function_declaration(name, arg_names, crystal_arg_types, crystal_ret_type)
      definition = ruby_code_block.lines[1..] # FIXME?
      crystal_code_block = definition.unshift(declaration).join
    end

    def function_declaration(name, arg_names, crystal_arg_types, crystal_ret_type)
      crystal_args = arg_names.zip(crystal_arg_types).map { |n, t| "#{n} : #{t}" }.join(', ')
      "fun #{name}(#{crystal_args}) : #{crystal_ret_type}\n"
    end

    def extract_ruby_method(name, line_number)
      exp = find_ruby_method(name, line_number)
      source = Sorcerer.source(exp, multiline: true, indent: true)
      arg_names = extract_arg_names(exp)
      [source, arg_names]
    end

    def extract_arg_names(exp)
      arg_names = []
      if exp[2][0] == :paren && (exp[2][1][0] == :params)
        exp[2][1][1].each do |arg|
          arg_names << arg[1] if arg[0] == :@ident
        end
      end
      arg_names
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
