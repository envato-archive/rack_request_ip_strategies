module RackRequestIPStrategies
  module ProxyFiltering
    def filter_proxies_from(header)
      filter_proxies(ips_from(header))
    end

    def filter_proxies(ips)
      ips.reject { |ip| trusted_proxy?(ip) }
    end

    def trusted_proxy?(ip)
      TrustedProxyDetector.trusted_proxy?(ip, @config.trusted_proxies)
    end
  end
end
