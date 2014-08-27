require 'spec_helper'

describe RackRequestIPStrategies do
  describe 'default config' do
    it 'uses results from X-Forwarded-For when available' do
      env = { 'HTTP_X_FORWARDED_FOR' => '200.200.200.200, 192.168.0.10', 'REMOTE_ADDR' => '200.200.200.200' }
      expect(RackRequestIPStrategies.calculate(env)).to eq '200.200.200.200'
    end
  end

  it 'accepts custom strategies that respond to call' do
    RackRequestIPStrategies.configure do |config|
      @previous_strategies = config.strategies
      config.strategies = [
        proc { |env| env['BLAH'] },
        proc { |env, config| config.strategies.count }
      ]
    end

    expect(RackRequestIPStrategies.calculate('BLAH' => '1')).to eq '1'
    expect(RackRequestIPStrategies.calculate({})).to eq 2

    RackRequestIPStrategies.configure do |config|
      config.strategies = @previous_strategies
    end
  end
end
