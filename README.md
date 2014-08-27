# RackRequestIPStrategies

This gem provides a replacement for `Rack::Request#ip` in order to allow its behaviour to be customized more easily.

## Why

This is the combination of various patches we had been maintaining in our Rails app.

- Prevents easy IP spoofing via `X-Forwarded-For` and `Client-IP` header manipulation. https://github.com/rack/rack/pull/705
- Without patching `Rack::Request#trusted_proxy?`, there's no way to add additional trusted proxies.

### Why not use Rails' `RemoteIP` middleware?

- Most middleware and Rails' logger use `request.ip`.

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

Define and use a custom strategy:

    class CustomStrategy
      def self.call(env, config)
        env['HTTP_MY_SPECIAL_IP_HEADER']
      end
    end

    RackRequestIPStrategies.configure do |config|
      # Try each strategy from left to right and use the first non-nil value
      config.strategies = [CustomStrategy, proc {|env| env['BLAH'] }, RackRequestIPStrategies::RemoteAddr]
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
