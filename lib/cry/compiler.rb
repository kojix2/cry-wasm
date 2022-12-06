module Cry
  class Compiler
    Options = Struct.new(:input, :output, :release, :export, :target, :link_flags)
    
    def initialize
      @options = Options.new
    end

    def options
      @options
    end

    def set_crystal_library_path(path = nil)
      if path
        ENV['CRYSTAL_LIBRARY_PATH'] = path
      else
        ENV['CRYSTAL_LIBRARY_PATH'] ||= File.expand_path('../../vendor/wasm32-wasi-libs', __dir__)
      end
    end

    def get_crystal_library_path
      ENV['CRYSTAL_LIBRARY_PATH']
    end

    def build_wasm(crystal_code, **opts)
      options.output = opts[:output] || nil
      options.release = opts[:release] || false
      options.export = opts[:export] || []
      options.target = opts[:target] || 'wasm32-wasi'
      options.link_flags = opts[:link_flags] || ''

      # Set CRYSTAL_LIBRARY_PATH
      set_crystal_library_path

      # Return compiled WASM bytes
      wasm_bytes = nil

      unless options.output
        output_tempfile = Tempfile.create('wasm')
        options.output = output_tempfile.path
      end

      unless options.input
        input_tempfile = Tempfile.create('crystal')
        options.input = input_tempfile.path
      end
      File.write(options.input, crystal_code)

      command = build_command
      result = system(command)
      input_tempfile&.close

      unless result
        warn '[cry-wasm] Failed to compile Crystal code to WASM'
        warn "[cry-wasm] #{command}"
        warn crystal_code
        raise 'crystal build failed' unless result
      end

      wasm_bytes = IO.read(options.output, mode: 'rb')
      output_tempfile&.close

      wasm_bytes
    end

    def build_command
      link_flags = "\"#{options.link_flags}" + options.export.map { |n| "--export #{n} " }.join + '"'
      "crystal build #{options.input} -o #{options.output} --target #{options.target} --link-flags=#{link_flags}"
    end
  end
end
