require "faraday"
require "multi_json"

module Zaikio::Client::Helpers
  superclass = if Gem.loaded_specs["faraday"].version >= Gem::Version.new("2.0")
    Faraday::Middleware
  else
    Faraday::Response::Middleware
  end

  JSONParser = Class.new(superclass) do
    def on_complete(env)
      case env.status
      when 404 then raise Spyke::ResourceNotFound.new(nil, url: env.url)
      when 429 then raise Zaikio::RateLimitedError.new(nil, url: env.url)
      when (200..299), 422 then env.body = parse_body(env.body, status: env.status)
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

    def parse_body(body, status: 200)
      json = MultiJson.load(body, symbolize_keys: true)
      errors = json.is_a?(Hash) ? json.delete(:errors) || {} : {}
      errors = { base: ['unknown'] } if status == 422 && errors.empty?
      {
        data: json,
        metadata: {},
        errors: errors
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
