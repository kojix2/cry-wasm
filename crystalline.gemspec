# frozen_string_literal: true

require_relative 'lib/crystalline/version'

Gem::Specification.new do |spec|
  spec.name          = 'Crystalline'
  spec.version       = Crystalline::VERSION
  spec.authors       = ['kojix2']
  spec.email         = ['2xijok@gmail.com']

  spec.summary       = 'Crystal Wasm Ruby'
  spec.description   = 'Crystal Wasm Ruby'
  spec.homepage      = 'https://github.com/kojix2/crystalline'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.7'

  spec.files = Dir['*.{md,txt}', '{lib}/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'sorcerer'
  spec.add_dependency 'wasmer'
end
