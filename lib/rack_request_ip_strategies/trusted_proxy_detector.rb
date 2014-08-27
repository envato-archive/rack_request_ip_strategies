module RackRequestIPStrategies
  class TrustedProxyDetector
    DEFAULT_TRUSTED_PROXIES = [
      "127.0.0.1",      # localhost IPv4
      "::1",            # localhost IPv6
      "fc00::/7",       # private IPv6 range fc00::/7
      "10.0.0.0/8",     # private IPv4 range 10.x.x.x
      "172.16.0.0/12",  # private IPv4 range 172.16.0.0 .. 172.31.255.255
      "192.168.0.0/16", # private IPv4 range 192.168.x.x
    ].map { |proxy| IPAddr.new(proxy) }

    def self.trusted_proxy?(ip, trusted_proxies = DEFAULT_TRUSTED_PROXIES)
      return false if ip.include?('/')

      trusted_proxies.any? do |proxy|
        proxy.include?(ip)
      end
    end
  end
end
