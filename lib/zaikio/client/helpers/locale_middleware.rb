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
            request_env.url.query = add_query_param(request_env.url.query, "lang", ::I18n.try(:locale))
          end

          @app.call(request_env)
        end

        private

        def add_query_param(query, key, value)
          query = [query.to_s]
          query << "&" unless query.empty?
          query << "#{Faraday::Utils.escape key}=#{Faraday::Utils.escape value}"

          query.join
        end
      end
    end
  end
end
