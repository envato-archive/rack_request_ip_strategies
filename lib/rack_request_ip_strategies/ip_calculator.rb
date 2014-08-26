require 'ipaddr'

module RackRequestIPStrategies
  class IPCalculator
    def initialize(config)
      @strategies = config.strategies
      @trusted_proxies = config.trusted_proxies
    end

    def calculate(env)
      ip = nil
      @strategies.each do |strategy|
        ip = strategy.calculate(env, @trusted_proxies)
        break if ip
      end
      ip
    end
  end
end
