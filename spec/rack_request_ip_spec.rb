require 'spec_helper'

describe Rack::Request, '#ip patched' do
  before do
    allow(RackRequestIPStrategies).to receive(:calculate)
  end

  it 'calls our calculate method' do
    env = double
    request = Rack::Request.new(env)
    request.ip
    expect(RackRequestIPStrategies).to have_received(:calculate).with(env)
  end
end
