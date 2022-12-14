require 'spec_helper'

RSpec.describe Cry::Wasm do
  it 'has a version number' do
    expect(Cry::Wasm::VERSION).not_to be nil
  end
end