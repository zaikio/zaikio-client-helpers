require "zaikio/client/model"
require "zaikio/client/helpers/json_parser"
require "zaikio/client/helpers/pagination"
require "zaikio/client/helpers/configuration"
require "zaikio/client/helpers/authorization_middleware"

module Zaikio
  module Client
    class << self
      def with_token(token)
        original_token = Helpers::AuthorizationMiddleware.token
        Helpers::AuthorizationMiddleware.token = token
        yield
      ensure
        Helpers::AuthorizationMiddleware.token = original_token
      end

      def create_connection(configuration)
        Faraday.new(url: configuration.host,
                                      ssl: { verify: configuration.environment != :test }) do |c|
          c.options.timeout = 5
          c.request     :json
          c.response    :logger, configuration&.logger, headers: false
          c.use         Zaikio::Client::Helpers::Pagination::FaradayMiddleware
          c.use         Zaikio::Client::Helpers::JSONParser
          c.use         Zaikio::Client::Helpers::AuthorizationMiddleware
          c.adapter     Faraday.default_adapter
        end
      end
    end
  end
end
