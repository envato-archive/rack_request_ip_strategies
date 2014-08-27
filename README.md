# RackRequestIPStrategies

This gem redefines `Rack::Request#ip` to allow the strategy used by your application to be configured based on your deployment setup. It also includes a bunch of fixes and improvements:

- The default strategy prevents IP spoofing via `X-Forwarded-For` and `Client-IP` header manipulation. https://github.com/rack/rack/pull/705
- Additional trusted proxies can be defined using CIDR notation.
- Custom strategies can be defined if you're behind a proxy that uses a different header.

## Installation

Add this line to your application's Gemfile:

    gem 'rack_request_ip_strategies', require: 'rack_request_ip_strategies/patch_rack'

Configure it:

    RackRequestIPStrategies.configure do |config|
      # defaults
      config.forwarding_header = 'HTTP_X_FORWARDED_FOR'
      config.strategies = [ForwardingHeader, RemoteAddr]
      config.trusted_proxies = TrustedProxyDetector::DEFAULT_TRUSTED_PROXIES

      # Add additional trusted proxies
      config.trusted_proxies += [IPAddr.new('199.27.128.0/21')]
    end

## Custom strategies

    class CustomStrategy
      def self.call(env, config)
        env['HTTP_MY_SPECIAL_IP_HEADER']
      end
    end

    RackRequestIPStrategies.configure do |config|
      # Try each strategy from left to right and use the first non-nil value
      config.strategies = [CustomStrategy, proc {|env| env['BLAH'] }, RackRequestIPStrategies::RemoteAddr]
    end

## When a trusted proxy is not involved

The default strategy assumes the `X-Forwarded-For` header is being set by a trusted proxy. If this is not the case then the application will be vulnerable to IP spoofing by clients setting that header. Overwrite the strategy to only use `REMOTE_ADDR` in this case.

    RackRequestIPStrategies.configure do |config|
      config.strategies = [RackRequestIPStrategies::RemoteAddr]
    end

## Usage

    # Standalone usage
    env = { 'HTTP_X_FORWARDED_FOR' => '200.200.200.200, 192.168.0.10', 'REMOTE_ADDR' => '192.168.0.10' }
    RackRequestIPStrategies.calculate(env)

## Contributing

1. Fork it ( http://github.com/envato/rack_request_ip_strategies/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
