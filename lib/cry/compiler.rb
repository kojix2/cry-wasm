require 'open3'

module Cry
  # Crystal compiler command wrapper class.
  # This class is used to compile Crystal code to WASM.
  # @example
  #  compiler = Cry::Compiler.new
  #  compiler.build_wasm('puts "Hello, World!"')
  class Compiler
    class CompilerError < StandardError; end

    # Crystal compiler options
    Options = Struct.new(:input, :output, :release, :export, :target, :link_flags)

    def initialize
      @options = Options.new
    end

    # Return compiler options
    # @return [Struct] compiler options
    attr_reader :options

    # Set CRYSTAL_LIBRARY_PATH
    # If path is not given, set default path
    # @param path [String] path to CRYSTAL_LIBRARY_PATH
    # @return [String]  CRYSTAL_LIBRARY_PATH

    def set_crystal_library_path(path = nil)
      if path
        ENV['CRYSTAL_LIBRARY_PATH'] = path
      else
        ENV['CRYSTAL_LIBRARY_PATH'] ||= File.expand_path('../../vendor/wasm32-wasi-libs', __dir__)
      end
    end

    # Return CRYSTAL_LIBRARY_PATH
    # @return [String] CRYSTAL_LIBRARY_PATH

    def get_crystal_library_path
      ENV['CRYSTAL_LIBRARY_PATH']
    end

    # Compile Crystal code to WASM
    # @param crystal_code [String] Crystal source code
    # @param opts [Hash] compiler options
    # @option opts [String] :output output wasm file path
    # @option opts [Boolean] :release release build
    # @option opts [Array<String>] :export export function names
    # @option opts [String] :target target triple
    # @option opts [String] :link_flags link flags
    # @return [String] compiled WASM bytes

    def build_wasm(crystal_code, **opts)
      set_options(crystal_code, **opts)

      command = build_command

      _o, error, status = Open3.capture3(command)
      @input_tempfile&.close

      unless status.success?
        warn build_error_message(crystal_code, command, error)
        raise CompilerError, 'Failed to compile Crystal code to WASM'
      end

      wasm_bytes = IO.read(options.output, mode: 'rb')
      @output_tempfile&.close

      wasm_bytes
    end

    # Set compiler options
    # @param crystal_code [String] Crystal source code
    # @param opts [Hash] compiler options
    # @option opts [String] :output output wasm file path
    # @option opts [Boolean] :release release build
    # @option opts [Array<String>] :export export function names
    # @option opts [String] :target target triple
    # @option opts [String] :link_flags link flags
    # @return [Struct] compiler options

    def set_options(crystal_code, **opts)
      options.output = opts[:output] || nil
      options.release = opts[:release] || false
      options.export = opts[:export] || []
      options.target = opts[:target] || 'wasm32-wasi'
      options.link_flags = opts[:link_flags] || ''

      # Set CRYSTAL_LIBRARY_PATH
      set_crystal_library_path

      # Set output (wasm bytecode) path
      unless options.output
        @output_tempfile = Tempfile.create('wasm')
        options.output = @output_tempfile.path
      end

      # Set input (crystal source) path
      input_tempfile = nil
      unless options.input
        @input_tempfile = Tempfile.create('crystal')
        options.input = @input_tempfile.path
      end
      File.write(options.input, crystal_code)

      options
    end

    # Return build command from options
    # @param options [Struct] compiler options
    # @return [String] build command

    def build_command(options = @options)
      link_flags = "\"#{options.link_flags}" + options.export.map { |n| "--export #{n} " }.join + '"'
      "crystal build #{options.input} -o #{options.output} --target #{options.target} --link-flags=#{link_flags}"
    end

    private

    def build_error_message(crystal_code, command, error)
      return <<~ERROR if error.include?('unable to find library')
        [cry-wasm] Failed to compile Crystal code to WASM
        [cry-wasm] Build command: \e[32m#{command}\e[0m
        [cry-wasm] CRYSTAL_LIBRARY_PATH: #{get_crystal_library_path}"
        [cry-wasm] #{error}
        [cry-wasm] Library not found.
        [cry-wasm] Please set CRYSTAL_LIBRARY_PATH to the path of the Crystal library for WASM.
        [cry-wasm] Or `bundle exec rake vendor:wasi_libs` to download the library.
      ERROR

      left_margin = crystal_code.split("\n").length.to_s.length
      matches = error.scan(/:(\d+):(\d+)/)
      line_number = matches[0][0].to_i if matches.any?
      column_number = matches[0][1].to_i if matches.any?

      <<~ERROR
        [cry-wasm] Failed to compile Crystal code to WASM
        [cry-wasm] Build command: \e[32m#{command}\e[0m
        [cry-wasm] CRYSTAL_LIBRARY_PATH: #{get_crystal_library_path}"
        #{crystal_code.split("\n").map.with_index do |line, i|
          if i == line_number - 1
            "[cry-wasm] \e[33m#{(i + 1).to_s.rjust(left_margin)}\e[0m #{line}\n" +
            "[cry-wasm] #{' ' * (column_number + left_margin)}\e[1m\e[32m^\e[0m"
          else
            "[cry-wasm] \e[33m#{(i + 1).to_s.rjust(left_margin)}\e[0m #{line}"
          end # {' '}
        end.join("\n")}
        [cry-wasm] Error: #{error}
      ERROR
    rescue StandardError
      <<~ERROR
        [cry-wasm] Failed to compile Crystal code to WASM
        [cry-wasm] #{error}
      ERROR
    end
  end
end
