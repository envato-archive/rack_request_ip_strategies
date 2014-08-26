module RackRequestIPStrategies
  class RemoteAddr < Base
    def calculate
      @env['REMOTE_ADDR']
    end
  end
end
