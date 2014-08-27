module RackRequestIPStrategies
  class RemoteAddr < Base
    def call
      @env['REMOTE_ADDR']
    end
  end
end
