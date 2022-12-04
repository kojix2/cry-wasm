# frozen_string_literal: true

require_relative 'lib/cry_wasm/version'

Gem::Specification.new do |spec|
  spec.name          = 'cry_wasm'
  spec.version       = CryWasm::VERSION
  spec.authors       = ['kojix2']
  spec.email         = ['2xijok@gmail.com']

  spec.summary       = 'Crystal Wasm Ruby'
  spec.description   = 'Crystal Wasm Ruby'
  spec.homepage      = 'https://github.com/kojix2/cry_wasm'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.7'

  spec.files = Dir['*.{md,txt}', '{lib}/**/*', '{vendor}/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'sorcerer'
  spec.add_dependency 'wasmer'
end
