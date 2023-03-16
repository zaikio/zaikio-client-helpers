require "faraday"

module Zaikio
  module Client
    module Helpers
      class LocaleMiddleware < Faraday::Middleware
        def initialize(app, disable_i18n: false)
          @disable_i18n = disable_i18n
          super(app)
        end

        def call(request_env)
          if !@disable_i18n && Object.const_defined?("I18n")
            request_env[:request_headers]["Accept-Language"] = ::I18n.try(:locale)&.to_s
          end

          @app.call(request_env)
        end
      end
    end
  end
end
