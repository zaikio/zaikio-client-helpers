# frozen_string_literal: true

require "test_helper"

class Zaikio::Client::HelpersTest < ActiveSupport::TestCase
  test "it has a version number" do
    refute_nil ::Zaikio::Client::Helpers::VERSION
  end
end
