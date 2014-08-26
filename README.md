# RackRequestIPStrategies

This gem provides a replacement implementation for `Rack::Request#ip` in order to allow its behaviour to be customized easily.

## What's wrong with `Rack::Request#ip`?


- It's return value can be easily spoofed when relying on the `X-Forwarded-For` header for the client IP. https://github.com/rack/rack/pull/705
- It provides no way to add additional trusted proxies.

## Why not use Rails' `RemoteIP` middleware?

- Most middleware and even the Rails logs use `request.ip` when a client IP is needed.

## Installation

Add this line to your application's Gemfile:

    gem 'rack_request_ip_strategies'

Configure it:

    RackRequestIPStrategies.configure do |config|
      config.trusted_proxies += %w[
        199.27.128.0/21
      ].map { |proxy| IPAddr.new(proxy) }
      config.strategies = [RackRequestIPStrategies::XForwardedFor, RackRequestIPStrategies::RemoteAddr] # default
    end

Patch Rack::Request#ip to use RackRequestIPStrategies.calculate(env)

    RackRequestIPStrategies.patch_rack

Define and use a custom strategy:

    class CustomStrategy
      def self.calculate(env)
        env['HTTP_MY_SPECIAL_IP_HEADER']
      end
    end

    RackRequestIPStrategies.configure do |config|
      # Try CustomStrategy first, if no value is returned, try RemoveAddr
      config.strategies = [CustomStrategy, RackRequestIPStrategies::RemoteAddr]
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
