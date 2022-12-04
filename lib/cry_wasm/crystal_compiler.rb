module CryWasm
  class CrystalCompiler
    def build_wasm(crystal_code, export:, out: nil)
      exported_methods = export
      wasm_out = out
      wasm_bytes = nil
      ENV['CRYSTAL_LIBRARY_PATH'] ||= File.expand_path('../../vendor/wasm32-wasi-libs', __dir__)
      unless wasm_out
        output_file = Tempfile.create('wasm')
        wasm_out = output_file.path
      end
      Tempfile.create('cry_wasm') do |crystal_file|
        File.write(crystal_file.path, crystal_code)
        link_flags = '"' + exported_methods.map { |n| "--export #{n} " }.join + '"'
        result = system(
          "crystal build #{crystal_file.path} -o #{wasm_out} --target wasm32-wasi --link-flags=#{link_flags}"
        )
        unless result
          warn 'Failed to compile Crystal code to WASM'
          warn crystal_code
          raise 'crystal build failed' unless result
        end
        wasm_bytes = IO.read(wasm_out, mode: 'rb')
      end
      output_file&.close
      wasm_bytes
    end
  end
end
