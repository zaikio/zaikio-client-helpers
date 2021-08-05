module Zaikio
  class Error < StandardError
    def initialize(message = nil, **opts)
      super(message)

      opts.each do |key, value|
        ivar = "@#{key}".to_sym
        instance_variable_set(ivar, value)
        define_singleton_method(key) { instance_variable_get(ivar) }
      end
    end
  end

  class ResourceNotFound < Zaikio::Error; end

  class ConnectionError < Zaikio::Error; end
  class RateLimitedError < ConnectionError; end
end

require "spyke"

module Spyke
  instance_eval do
    # avoid warning: already initialized constant
    remove_const("ConnectionError")
    remove_const("ResourceNotFound")
  end

  ConnectionError = Zaikio::ConnectionError
  ResourceNotFound = Zaikio::ResourceNotFound
end
