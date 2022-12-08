require 'sorcerer'
require_relative 'codegen/ruby_method'
require_relative 'codegen/crystal_function'
require_relative 'codegen/crystallizer'

module Cry
  class Codegen
    attr_accessor :sexp, :crystal_code_blocks, :function_names
    attr_reader :source_path

    def initialize
      @sexp = nil
      @source_path = nil
      @function_names = [] # Function names to be exported
      @crystal_code_blocks = []
    end

    def source_path=(fname)
      # In most cases, previously parsed S-expressions can be reused.
      # However, if the class definition is in the multiple files,
      # such as when using Open classes, the S-expressions must be re-parsed.
      if @source_path != fname
        str = IO.read(fname)
        @sexp = Ripper::SexpBuilder.new(str).parse
      end
      @source_path = fname
    end

    def crystal_code
      @crystal_code_blocks.join("\n")
    end

    def add_crystal_function(name, crystal_arg_types, crystal_ret_type, line_number)
      @function_names << name
      @crystal_code_blocks << crystalize(name, crystal_arg_types, crystal_ret_type, line_number)
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
