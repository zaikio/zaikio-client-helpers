# frozen_string_literal: true

require "test_helper"

class Zaikio::Client::Helpers::ConfigurationTest < ActiveSupport::TestCase
  def setup
    @config_class = Class.new(Zaikio::Client::Helpers::Configuration) do
      def self.hosts
        {
          development: "https://procurement.zaikio.test/api/v2/",
          test: "https://procurement.zaikio.test/api/v2/",
          staging: "https://procurement.staging.zaikio.com/api/v2/",
          sandbox: "https://procurement.sandbox.zaikio.com/api/v2/",
          production: "https://procurement.zaikio.com/api/v2/"
        }.freeze
      end
    end
  end

  test "creates default configuration" do
    configuration = @config_class.new
    assert_equal :sandbox, configuration.environment
    assert_equal "https://procurement.sandbox.zaikio.com/api/v2/", configuration.host
    configuration.environment = :test
    assert_equal "https://procurement.zaikio.test/api/v2/", configuration.host
  end
end
