module RackRequestIPStrategies
  class Base
    def self.calculate(env, config = Config.default)
      new(env, config).calculate
    end

    def initialize(env, config)
      @env = env
      @config = config
    end

    private

    def ips_from(header)
      ips = @env[header] ? @env[header].strip.split(/[,\s]+/) : []
      ips.select { |ip| valid_ip?(ip) }
    end

    def valid_ip?(ip)
      return false if ip.include?('/')
      IPAddr.new(ip)
    rescue ArgumentError, IPAddr::InvalidAddressError
      nil
    end
  end
end
