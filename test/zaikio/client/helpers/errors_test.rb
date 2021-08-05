# frozen_string_literal: true

require "test_helper"

class Zaikio::Client::Helpers::ErrorsTest < ActiveSupport::TestCase
  test "rescues correctly with Spyke::ConnectionError" do
    rescued = false
    begin
      raise Zaikio::RateLimitedError
    rescue Spyke::ConnectionError => e
      rescued = true
    end

    assert rescued
  end
end
