require "rack_request_ip_strategies/version"
require "rack_request_ip_strategies/proxy_filtering"
require "rack_request_ip_strategies/base"
require "rack_request_ip_strategies/remote_addr"
require "rack_request_ip_strategies/forwarding_header"
require "rack_request_ip_strategies/ip_calculator"
require "rack_request_ip_strategies/trusted_proxy_detector"

module RackRequestIPStrategies
  extend self

  class Config
    attr_accessor :strategies, :trusted_proxies, :forwarding_header

    def self.default
      new.tap do |config|
        config.forwarding_header = 'HTTP_X_FORWARDED_FOR'
        config.strategies = [ForwardingHeader, RemoteAddr]
        config.trusted_proxies = TrustedProxyDetector::DEFAULT_TRUSTED_PROXIES
      end
    end
  end

  def configure
    @calculator = nil
    yield config
  end

  def calculate(env)
    calculator.calculate(env)
  end

  def patch_rack
    require "rack"

    Rack::Request.send(:define_method, :ip) do
      RackRequestIPStrategies.calculate(@env)
    end
  end

  private

  def calculator
    @calculator ||= IPCalculator.new(config)
  end

  def config
    @config ||= Config.default
  end
end
