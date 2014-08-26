require 'rubygems'
require 'bundler/setup'

$:.unshift 'lib'

require 'rack_request_ip_strategies'

RackRequestIPStrategies.patch_rack

require 'pry'
