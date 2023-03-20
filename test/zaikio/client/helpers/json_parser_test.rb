# frozen_string_literal: true

require "test_helper"

class Zaikio::Client::Helpers::JSONParserTest < ActiveSupport::TestCase
  def setup
    @connection = Faraday.new(url: "https://parse") do |f|
      f.use Zaikio::Client::Helpers::JSONParser
    end
  end

  test "parses some JSON in the happy path" do
    stub_request(:get, "https://parse/").to_return(body: '[{"id": 1}]')

    response = @connection.get("/")

    assert_equal({
      data: [{id: 1}],
      metadata: {},
      errors: {}
    }, response.body)
  end

  test "parses error JSON in the happy path" do
    stub_request(:get, "https://parse/").to_return(body: '{"errors": {"uh":"oh"}}')

    response = @connection.get("/")

    assert_equal({
      data: {},
      metadata: {},
      errors: {uh: "oh"}
    }, response.body)
  end

  test "when server returns HTTP 500" do
    stub_request(:get, "https://parse/").to_return(status: 503, body: "Service unavailable")

    exception = assert_raises(Spyke::ConnectionError) do
      @connection.get("/")
    end
    assert_equal "Status: 503, URL: https://parse/, body: Service unavailable", exception.message
    assert_equal 503, exception.status
    assert_equal URI("https://parse/"), exception.url
    assert_equal "Service unavailable", exception.body
  end

  test "when server returns HTTP 422" do
    stub_request(:patch, "https://parse/").to_return(status: 422, body: %({"errors":{}}))

    response = assert_nothing_raised do
      @connection.patch("/")
    end

    assert_equal({:data=>{}, :metadata=>{}, :errors=>{ base: ["unknown"] }}, response.body)
  end

  test "when server returns HTTP 422 with given error message" do
    stub_request(:patch, "https://parse/").to_return(status: 422, body: %({"errors":{"base": ["error_message"]}}))

    response = assert_nothing_raised do
      @connection.patch("/")
    end

    assert_equal({:data=>{}, :metadata=>{}, :errors=>{ base: ["error_message"] }}, response.body)
  end

  test "when server returns HTTP 429" do
    stub_request(:get, "https://parse/").to_return(status: 429, body: "Rate limited")

    exception = assert_raises(Zaikio::RateLimitedError) do
      @connection.get("/")
    end
    assert_equal URI("https://parse/"), exception.url
  end

  test "returns 404 if resource not found" do
    stub_request(:get, "https://parse/").to_return(status: 404)

    exception = assert_raises(Spyke::ResourceNotFound) do
      @connection.get("/")
    end

    assert_equal URI("https://parse/"), exception.url
  end
end
