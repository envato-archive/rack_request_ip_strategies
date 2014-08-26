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

    def filter_proxies_from(header)
      filter_proxies(ips_from(header))
    end

    def filter_proxies(ips)
      ips.reject { |ip| trusted_proxy?(ip) }
    end

    def trusted_proxy?(ip)
      TrustedProxyDetector.trusted_proxy?(ip, @config.trusted_proxies)
    end

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
