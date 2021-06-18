# frozen_string_literal: true

require "test_helper"

class Zaikio::Client::Helpers::Pagination::FaradayMiddlewareTest < ActiveSupport::TestCase
  def setup
    @connection = Faraday.new(url: "https://empty") do |f|
      f.use Zaikio::Client::Helpers::Pagination::FaradayMiddleware
    end
  end

  test "it sets the total_count, total_pages and current_page properties" do
    stub_request(:get, "https://empty")
      .to_return(status: 200, headers: {
        "Total-Count" => 0,
        "Total-Pages" => 1,
        "Current-Page" => 1,
      })

    response = @connection.get("/")

    assert_equal 0, response.env[:pagination][:total_count]
    assert_equal 1, response.env[:pagination][:total_pages]
    assert_equal 1, response.env[:pagination][:current_page]
  end

  test "it does not break if headers absent" do
    stub_request(:get, "https://empty")
      .to_return(status: 200, headers: {})

    response = @connection.get("/")

    assert_nil response.env[:pagination][:total_count]
    assert_nil response.env[:pagination][:total_pages]
    assert_nil response.env[:pagination][:current_page]
  end
end

class Zaikio::Client::Helpers::Pagination::SpykeTest < ActiveSupport::TestCase
  class User < Spyke::Base
    include Zaikio::Client::Helpers::Pagination::Spyke
  end

  def setup
    Spyke::Base.connection = Faraday.new(url: "https://api") do |f|
      f.use Zaikio::Client::Helpers::Pagination::FaradayMiddleware
      f.use Zaikio::Client::Helpers::JSONParser
    end
    @headers = { "Content-Type" => "application/json" }
  end

  test "#all only fetches one page if present" do
    headers = {
      "Total-Count" => 2,
      "Total-Pages" => 1,
      "Current-Page" => 1,
    }
    stub_request(:get, "https://api/users").
      to_return(status: 200, headers: headers.merge(@headers), body: '[{"id":1}, {"id":2}]')

    users = User.all
    assert_equal [1,2], users.map(&:id)
  end

  test "#all fetches further pages if present" do
    stub_request(:get, "https://api/users").to_return(body: '[{"id":1}]', headers: {
      "Total-Count" => 3,
      "Total-Pages" => 3,
      "Current-Page" => 1,
      **@headers
    })
    stub_request(:get, "https://api/users?page=2").to_return(body: '[{"id":2}]', headers: {
      "Total-Count" => 3,
      "Total-Pages" => 3,
      "Current-Page" => 2,
      **@headers
    })
    stub_request(:get, "https://api/users?page=3").to_return(body: '[{"id":3}]', headers: {
      "Total-Count" => 3,
      "Total-Pages" => 3,
      "Current-Page" => 3,
      **@headers
    })

    users = User.all.to_a
    assert_equal [1,2,3], users.map(&:id)
  end

  test "#all preserves query params & scope when recursing" do
    stub_request(:get, "https://api/special_users?foo=bar").to_return(body: '[{"id":1}]', headers: {
      "Total-Count" => 2,
      "Total-Pages" => 2,
      "Current-Page" => 1,
      **@headers
    })
    stub_request(:get, "https://api/special_users?foo=bar&page=2").to_return(body: '[{"id":2}]', headers: {
      "Total-Count" => 2,
      "Total-Pages" => 2,
      "Current-Page" => 2,
      **@headers
    })

    users = User.with("/special_users").where(foo: :bar).to_a
    assert_equal [1,2], users.map(&:id)
  end

  test "#all works with #lazy to #take just the first page" do
    stub_request(:get, "https://api/users").to_return(body: '[{"id":1}]', headers: {
      "Total-Count" => 3,
      "Total-Pages" => 3,
      "Current-Page" => 1,
      **@headers
    })

    users = User.all.lazy.take(1).to_a
    assert_equal [1], users.map(&:id)
  end

  test "page methods on first page of 2" do
    stub_request(:get, "https://api/users").to_return(body: '[{"id":1}]', headers: {
      "Total-Count" => 3,
      "Total-Pages" => 2,
      "Current-Page" => 1,
      **@headers
    })

    relation = User.all
    assert relation.supports_pagination?
    assert relation.first_page?
    refute relation.last_page?
    assert_equal 2, relation.next_page
  end

  test "page methods on last page of 2" do
    stub_request(:get, "https://api/users").to_return(body: '[{"id":1}]', headers: {
      "Total-Count" => 3,
      "Total-Pages" => 2,
      "Current-Page" => 2,
      **@headers
    })

    relation = User.all
    assert relation.supports_pagination?
    refute relation.first_page?
    assert relation.last_page?
  end

  test "does not attempt to paginate if missing pagination headers" do
    stub_request(:get, "https://api/users").to_return(body: '[{"id":1}]', headers: @headers)

    relation = User.all
    assert_equal [1], relation.map(&:id)

    refute relation.supports_pagination?
  end
end
