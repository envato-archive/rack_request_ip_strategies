require 'spec_helper'

describe RackRequestIPStrategies::ForwardingHeader do
  it 'prioritises REMOTE_ADDR if it contains a non-trusted proxy' do
    env = { 'HTTP_X_FORWARDED_FOR' => '200.100.100.100, 192.168.0.10',
            'REMOTE_ADDR' => '100.100.100.100' }
    expect(RackRequestIPStrategies::ForwardingHeader.call(env)).to eq '100.100.100.100'
  end

  it 'falls back to REMOTE_ADDR' do
    env = { 'REMOTE_ADDR' => '127.0.0.1' }
    expect(RackRequestIPStrategies::ForwardingHeader.call(env)).to eq '127.0.0.1'
  end

  it 'takes the last IP after filtering known proxies' do
    env = { 'HTTP_X_FORWARDED_FOR' => '100.100.100.100, 192.168.0.10' }
    expect(RackRequestIPStrategies::ForwardingHeader.call(env)).to eq '100.100.100.100'
  end

  it 'returns nil if no non-trusted IP addresses are found' do
    env = { 'HTTP_X_FORWARDED_FOR' => '192.168.0.11, 192.168.0.10' }
    expect(RackRequestIPStrategies::ForwardingHeader.call(env)).to eq nil
  end

  it 'rejects invalid IP addresses' do
    env = { 'HTTP_X_FORWARDED_FOR' => '192.168.0.11.0, 192.168.0.10' }
    expect(RackRequestIPStrategies::ForwardingHeader.call(env)).to eq nil
  end

  it 'rejects IP addresses with a range' do
    env = { 'HTTP_X_FORWARDED_FOR' => '192.168.0.0/24, 192.168.0.10' }
    expect(RackRequestIPStrategies::ForwardingHeader.call(env)).to eq nil
  end

  context 'configuration' do
    it 'can be configured with a custom header' do
      env = { 'HTTP_X_REAL_IP' => '20.20.20.20, 192.168.0.20, 192.168.0.10' }
      allow(RackRequestIPStrategies::ForwardingHeader.config).to receive(:header).and_return('HTTP_X_REAL_IP')
      expect(RackRequestIPStrategies::ForwardingHeader.call(env)).to eq '20.20.20.20'
    end

    it 'can be configured with additional trusted proxies' do
      env = { 'HTTP_X_FORWARDED_FOR' => '100.100.100.100, 104.16.12.9, 192.168.0.10' }
      RackRequestIPStrategies::ForwardingHeader.configure do |config|
        trusted_proxies = RackRequestIPStrategies::TrustedProxyDetector::DEFAULT_TRUSTED_PROXIES + [IPAddr.new('104.16.12.9')]
        allow(config).to receive(:trusted_proxies).and_return(trusted_proxies)
      end
      expect(RackRequestIPStrategies::ForwardingHeader.call(env)).to eq '100.100.100.100'
    end
  end
end
