require 'sorcerer'

module Cry
  class Codegen
    class RubyMethod
      attr_accessor :name, :arg_names, :source

      def initialize(name = nil, arg_names = [], source = nil)
        @name = name
        @arg_names = arg_names
        @source = source
      end

      class << self
        def new_from_sexp(name, exp)
          source = Sorcerer.source(exp, multiline: true, indent: true)
          arg_names = extract_arg_names(exp)
          RubyMethod.new(name, arg_names, source)
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
      end
    end
  end
end
