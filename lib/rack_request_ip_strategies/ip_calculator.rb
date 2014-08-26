require 'ipaddr'

module RackRequestIPStrategies
  class IPCalculator
    def initialize(config)
      @config = config
      @strategies = config.strategies
    end

    def calculate(env)
      ip = nil
      @strategies.each do |strategy|
        ip = strategy.calculate(env, @config)
        break if ip
      end
      ip
    end
  end
end
