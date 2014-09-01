module RackRequestIPStrategies
  class ForwardingHeader
    class Config
      attr_accessor :trusted_proxies,
                    :header

      def self.default
        new.tap do |config|
          config.header = 'HTTP_X_FORWARDED_FOR'
          config.trusted_proxies = TrustedProxyDetector::DEFAULT_TRUSTED_PROXIES
        end
      end
    end

    def self.configure
      yield config
    end

    def self.config
      @config ||= Config.default
    end

    def self.call(env)
      new(env, config).call
    end

    def initialize(env, config)
      @env = env
      @config = config
    end

    def call
      # Give priority to REMOTE_ADDR if it's a non-trusted proxy
      remote_addr = filter_proxies_from('REMOTE_ADDR').last

      # Return the IP after the last trusted proxy in the forwarding header
      remote_addr || filter_proxies_from(@config.header).last
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
      return false if ip.nil? || ip.include?('/')
      IPAddr.new(ip)
    rescue ArgumentError, IPAddr::InvalidAddressError
      false
    end
  end
end
