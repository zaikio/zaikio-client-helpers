require "faraday"

module Zaikio
  module Client
    module Helpers
      class AuthorizationMiddleware < Faraday::Middleware
        def self.token
          Thread.current[:zaikio_client_access_token]
        end

        def self.token=(value)
          Thread.current[:zaikio_client_access_token] = value
        end

        def self.reset_token
          Thread.current[:zaikio_client_access_token] = nil
        end

        def call(request_env)
          request_env[:request_headers]["Authorization"] = "Bearer #{self.class.token}" if self.class.token

          @app.call(request_env)
        end
      end
    end
  end
end
