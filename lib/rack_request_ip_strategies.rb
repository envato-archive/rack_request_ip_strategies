require "rack_request_ip_strategies/version"
require "rack_request_ip_strategies/remote_addr"
require "rack_request_ip_strategies/forwarding_header"
require "rack_request_ip_strategies/trusted_proxy_detector"

module RackRequestIPStrategies
  extend self

  attr_accessor :strategy
  self.strategy = ForwardingHeader

  def calculate(env)
    strategy.call(env)
  end

  def patch_rack
    require "rack"

    Rack::Request.send(:define_method, :ip) do
      @env.fetch("rack_request_ip_strategies.ip") do
        @env["rack_request_ip_strategies.ip"] = RackRequestIPStrategies.calculate(@env)
      end
    end
  end
end
