require 'spec_helper'

describe RackRequestIPStrategies::RemoteAddr do
  it 'takes REMOTE_ADDR verbatim' do
    expect(RackRequestIPStrategies::RemoteAddr.calculate('REMOTE_ADDR' => 'blah')).to eq 'blah'
  end
end
