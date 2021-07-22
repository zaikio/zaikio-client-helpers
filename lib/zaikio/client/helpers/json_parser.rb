require "faraday"
require "multi_json"

module Zaikio::Client::Helpers
  class JSONParser < Faraday::Response::Middleware
    def on_complete(env)
      case env.status
      when 404 then raise Spyke::ResourceNotFound.new(nil, url: env.url)
      when 429 then raise Zaikio::RateLimitedError.new(nil, url: env.url)
      when (200..299), 422 then env.body = parse_body(env.body)
      else connection_error(env)
      end
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
