# RackRequestIPStrategies

The implementation of `Rack::Request#ip` has some issues:

- The latest version (1.5.2) contains a vulnerability that allows easy IP spoofing via header manipulation. https://github.com/rack/rack/pull/705
- There's no easy way to define additional trusted proxies.

This gem redefines `Rack::Request#ip` to call `RackRequestIPStrategies.calculate(@env)`, which delegates to the chosen strategy. The `ForwardingHeader` strategy allows additional trusted proxies to be defined using CIDR notation, prioritising `REMOTE_ADDR` if it contains a non-trusted proxy.

## Installation

Add this line to your application's Gemfile:

    gem 'rack_request_ip_strategies', require: 'rack_request_ip_strategies/patch_rack'

## Configuration

By default the gem uses the `ForwardingHeader` strategy configured with the `X-Forwarded-For` header.

    RackRequestIPStrategies.strategy = RackRequestIPStrategies::ForwardingHeader

    RackRequestIPStrategies::ForwardingHeader.configure do |config|
      # defaults
      config.header = 'HTTP_X_FORWARDED_FOR'
      config.trusted_proxies = TrustedProxyDetector::DEFAULT_TRUSTED_PROXIES

      # Add additional trusted proxies
      config.trusted_proxies += [IPAddr.new('199.27.128.0/21')]
    end

## Custom strategies

    class CustomStrategy
      def self.call(env)
        env['HTTP_MY_SPECIAL_IP_HEADER']
      end
    end

    RackRequestIPStrategies.strategy = CustomStrategy

## Standalone usage

    env = { 'HTTP_X_FORWARDED_FOR' => '200.200.200.200, 192.168.0.10', 'REMOTE_ADDR' => '192.168.0.10' }
    RackRequestIPStrategies.calculate(env)
    => "200.200.200.200"

## Contributing

1. Fork it ( http://github.com/envato/rack_request_ip_strategies/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
