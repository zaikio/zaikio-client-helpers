require "faraday"
require "multi_json"

module Zaikio::Client::Helpers
  class JSONParser < Faraday::Response::Middleware
    def on_complete(env)
      connection_error(env) unless /^(2\d\d)|422|404$/.match?(env.status.to_s)

      raise Spyke::ResourceNotFound.new("Not found", url: env.url) if env.status.to_s == "404"

      env.body = parse_body(env.body)
    end

    def connection_error(env)
      raise Spyke::ConnectionError.new(
        "Status: #{env.status}, URL: #{env.url}, body: #{env.body}",
        status: env.status,
        url: env.url,
        body: env.body
      )
    end

    def parse_body(body)
      json = MultiJson.load(body, symbolize_keys: true)
      {
        data: json,
        metadata: {},
        errors: json.is_a?(Hash) ? json[:errors] : {}
      }
    rescue MultiJson::ParseError
      {
        data: {},
        metadata: {},
        errors: {}
      }
    end
  end
end
