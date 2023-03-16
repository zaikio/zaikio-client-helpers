# frozen_string_literal: true

require "test_helper"

class Zaikio::Client::Helpers::LocaleMiddlewareTest < ActiveSupport::TestCase
  def create_connection(disable_i18n: false)
    @config_class = Class.new(Zaikio::Client::Helpers::Configuration) do
      def self.hosts
        {
          sandbox: "https://procurement.sandbox.zaikio.com/api/v2/"
        }.freeze
      end
    end
    @config = @config_class.new
    @config.disable_i18n = disable_i18n
    Zaikio::Client.create_connection(@config)
  end

  test "it sets the lang query param" do
    @connection = create_connection
    
    stub_request(:get, "https://procurement.sandbox.zaikio.com/api/v2/resources?anotherparam=1&lang=de")

    I18n.with_locale(:de) do
      Zaikio::Client.with_token("token") do
        @connection.get("resources?anotherparam=1")
      end
    end

    assert_requested(
      :get, "https://procurement.sandbox.zaikio.com/api/v2/resources?anotherparam=1&lang=de",
      headers: { "Authorization" => "Bearer token" }
    )
  end

  test "it does not set the lang query param if disabled" do
    @connection = create_connection(disable_i18n: true)
    stub_request(:get, "https://procurement.sandbox.zaikio.com/api/v2/resources?anotherparam=1")

    I18n.with_locale(:de) do
      Zaikio::Client.with_token("token") do
        @connection.get("resources?anotherparam=1")
      end
    end

    assert_requested(
      :get, "https://procurement.sandbox.zaikio.com/api/v2/resources?anotherparam=1",
      headers: { "Authorization" => "Bearer token" }
    )
  end
end
