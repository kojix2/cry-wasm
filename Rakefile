# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :vendor do
  desc 'Download WebAssembly Libs for WASI.'
  task :wasi_libs do
    sh <<~CMD
      curl -OL https://github.com/lbguilherme/wasm-libs/releases/download/0.0.2/wasm32-wasi-libs.tar.gz &&
      mkdir -p vendor/wasm32-wasi-libs &&
      tar -xvf wasm32-wasi-libs.tar.gz -C vendor/wasm32-wasi-libs &&
      rm wasm32-wasi-libs.tar.gz
    CMD
  end
end
