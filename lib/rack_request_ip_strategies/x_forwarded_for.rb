module RackRequestIPStrategies
  class XForwardedFor < Base
    def calculate
      filter_proxies_from('HTTP_X_FORWARDED_FOR').last
    end
  end
end
