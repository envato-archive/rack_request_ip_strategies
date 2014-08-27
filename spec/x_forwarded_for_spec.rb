require 'spec_helper'

describe RackRequestIPStrategies::ForwardingHeader do
  it 'takes the last IP after filtering known proxies' do
    env = { 'HTTP_X_FORWARDED_FOR' => '100.100.100.100, 192.168.0.10' }
    expect(RackRequestIPStrategies::ForwardingHeader.calculate(env)).to eq '100.100.100.100'
  end

  it 'returns nil if no non-trusted IP addresses are found' do
    env = { 'HTTP_X_FORWARDED_FOR' => '192.168.0.11, 192.168.0.10' }
    expect(RackRequestIPStrategies::ForwardingHeader.calculate(env)).to eq nil
  end

  it 'rejects invalid IP addresses' do
    env = { 'HTTP_X_FORWARDED_FOR' => '192.168.0.11.0, 192.168.0.10' }
    expect(RackRequestIPStrategies::ForwardingHeader.calculate(env)).to eq nil
  end

  it 'rejects IP addresses with a range' do
    env = { 'HTTP_X_FORWARDED_FOR' => '192.168.0.0/24, 192.168.0.10' }
    expect(RackRequestIPStrategies::ForwardingHeader.calculate(env)).to eq nil
  end

  it 'can be configured with a custom header' do
    env = { 'HTTP_X_REAL_IP' => '192.168.0.20, 192.168.0.10' }
    config = RackRequestIPStrategies::Config.default.tap do |config|
      config.forwarding_header = 'HTTP_X_REAL_IP'
    end
    expect(RackRequestIPStrategies::ForwardingHeader.calculate(env, config)).to eq nil
  end
end
