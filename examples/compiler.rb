require 'cry/wasm'

compiler = Cry::Compiler.new

wasm_bytes = compiler.build_wasm <<~CRYSTAL
  p Crystal::BUILD_COMMIT
  p Crystal::BUILD_DATE
  p Crystal::CACHE_DIR
  p Crystal::DEFAULT_PATH
  p Crystal::DESCRIPTION
  p Crystal::LIBRARY_PATH
  p Crystal::LLVM_VERSION
  p Crystal::PATH
  p Crystal::VERSION
  puts "Hello, Crystal World!"
CRYSTAL

Cry::Wasmer.new(wasm_bytes).start
