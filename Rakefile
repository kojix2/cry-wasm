# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

namespace :vendor do
  desc 'Install vendor dependencies'
  task :wasi_libs do
    sh <<~CMD
      curl -OL https://github.com/lbguilherme/wasm-libs/releases/download/0.0.2/wasm32-wasi-libs.tar.gz &&
      mkdir -p vendor/wasm32-wasi-libs &&
      tar -xvf wasm32-wasi-libs.tar.gz -C vendor/wasm32-wasi-libs &&
      rm wasm32-wasi-libs.tar.gz
    CMD
  end
end
