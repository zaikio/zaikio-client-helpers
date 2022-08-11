require "logger"

module Zaikio
  module Client
    module Helpers
      class Configuration
        attr_accessor :host
        attr_reader :environment
        attr_writer :logger

        def self.hosts
          raise "implement me"
        end

        def initialize
          self.environment = :sandbox
        end

        def logger
          @logger ||= Logger.new($stdout)
        end

        def environment=(env)
          @environment = env.to_sym
          @host = host_for(environment)
        end

        private

        def host_for(environment)
          self.class.hosts.fetch(environment) do
            raise StandardError.new, "Invalid Zaikio::Client environment '#{environment}'"
          end
        end
      end
    end
  end
end
