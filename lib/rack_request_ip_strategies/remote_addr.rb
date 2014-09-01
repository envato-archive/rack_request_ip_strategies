module RackRequestIPStrategies
  class RemoteAddr
    def self.call(env)
      env['REMOTE_ADDR']
    end
  end
end
