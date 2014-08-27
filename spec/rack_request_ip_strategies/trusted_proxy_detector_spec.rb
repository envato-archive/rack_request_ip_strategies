require 'spec_helper'

describe RackRequestIPStrategies::TrustedProxyDetector do
  subject { RackRequestIPStrategies::TrustedProxyDetector }

  describe 'default trusted proxies' do
    it { should be_trusted_proxy('127.0.0.1') }
    it { should be_trusted_proxy('::1') }
    it { should be_trusted_proxy('0:0:0:0:0:0:0:1') }
    it { should be_trusted_proxy('fd92:de72:a8f5:ddf3:0000:0000:0000:0000') }
    it { should be_trusted_proxy('172.16.0.0') }
    it { should be_trusted_proxy('172.16.0.10') }
    it { should be_trusted_proxy('192.168.0.0') }
    it { should be_trusted_proxy('192.168.0.10') }
    it { should_not be_trusted_proxy('199.27.128.1') }
  end

  context 'custom trusted proxies' do
    let(:trusted_proxies) { [IPAddr.new('199.27.128.0/21')] }

    it { should_not be_trusted_proxy('127.0.0.1', trusted_proxies) }
    it { should be_trusted_proxy('199.27.128.1', trusted_proxies) }
  end

  context 'ip is a range' do
    it { should_not be_trusted_proxy('192.168.0.0/24') }
  end
end
