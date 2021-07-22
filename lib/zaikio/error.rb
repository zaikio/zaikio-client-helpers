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

  class ConnectionError < Zaikio::Error; end
  class ResourceNotFound < Zaikio::Error; end
end

require "spyke"

module Spyke
  instance_eval do
    # avoid warning: already initialized constant
    remove_const("ConnectionError")
    remove_const("ResourceNotFound")
  end

  ConnectionError = Class.new Zaikio::ConnectionError
  ResourceNotFound = Class.new Zaikio::ResourceNotFound
end