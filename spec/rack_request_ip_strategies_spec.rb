require 'spec_helper'

describe RackRequestIPStrategies do
  describe 'default config' do
    it 'uses results from X-Forwarded-For when available' do
      env = { 'HTTP_X_FORWARDED_FOR' => '200.200.200.200, 192.168.0.10', 'REMOTE_ADDR' => '200.200.200.200' }
      expect(RackRequestIPStrategies.calculate(env)).to eq '200.200.200.200'
    end
  end
end
