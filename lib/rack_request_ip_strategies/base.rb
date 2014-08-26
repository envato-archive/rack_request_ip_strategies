module RackRequestIPStrategies
  class Base
    def self.calculate(env, trusted_proxies = TrustedProxyDetector::DEFAULT_TRUSTED_PROXIES)
      new(env, trusted_proxies).calculate
    end

    def initialize(env, trusted_proxies)
      @env = env
      @trusted_proxies = trusted_proxies
    end

    private

    def filter_proxies_from(header)
      filter_proxies(ips_from(header))
    end

    def filter_proxies(ips)
      ips.reject { |ip| trusted_proxy?(ip) }
    end

    def trusted_proxy?(ip)
      TrustedProxyDetector.trusted_proxy?(ip, @trusted_proxies)
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
