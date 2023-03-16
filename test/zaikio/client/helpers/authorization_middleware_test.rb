# frozen_string_literal: true

require "test_helper"

class Zaikio::Client::Helpers::AuthorizationMiddlewareTest < ActiveSupport::TestCase
  def setup
    @config_class = Class.new(Zaikio::Client::Helpers::Configuration) do
      def self.hosts
        {
          sandbox: "https://procurement.sandbox.zaikio.com/api/v2/"
        }.freeze
      end
    end
    @connection = Zaikio::Client.create_connection(@config_class.new)
  end

  test "it sets the Authorization request header" do
    stub_request(:get, "https://procurement.sandbox.zaikio.com/api/v2/resources?lang=en")
    stub_request(:get, "https://procurement.sandbox.zaikio.com/api/v2/resources2?lang=en")

    Zaikio::Client.with_token("oldtoken") do
      Zaikio::Client.with_token("mytoken") do
        @connection.get("resources2")
      end

      @connection.get("resources")
    end

    assert_requested(
      :get, "https://procurement.sandbox.zaikio.com/api/v2/resources?lang=en",
      headers: { "Authorization" => "Bearer oldtoken" }
    )

    assert_requested(
      :get, "https://procurement.sandbox.zaikio.com/api/v2/resources2?lang=en",
      headers: { "Authorization" => "Bearer mytoken" }
    )
  end
end
