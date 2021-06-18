require "faraday"
require "spyke"

module Zaikio::Client::Helpers
  module Pagination
    HEADERS = {
      total_count: "Total-Count",
      total_pages: "Total-Pages",
      current_page: "Current-Page"
    }.freeze

    METADATA_KEY = :pagination

    # Faraday Middleware for extracting any pagination headers into the a top-level
    # :metadata hash, or the env hash for non-JSON responses.
    #
    # @example Usage
    #   conn = Faraday.new do |f|
    #     f.use Zaikio::Client::Helpers::Pagination::FaradayMiddleware
    #   end
    #
    #   response = conn.get("/")
    #   response.env[METADATA_KEY]
    #   #=> {total_count: 4, total_pages: 1, current_page: 1}
    class FaradayMiddleware < Faraday::Response::Middleware
      def on_complete(env)
        @env = env

        metadata = HEADERS.transform_values do |key|
          header(key)
        end

        if env.body.is_a?(Hash)
          @env.body[:metadata] ||= {}
          @env.body[:metadata][METADATA_KEY] = metadata
        else
          @env[METADATA_KEY] = metadata
        end
      end

      private

      def header(key)
        value = @env.response_headers[key]
        value.try(:to_i)
      end
    end

    extend ActiveSupport::Concern

    included do
      scope :page, ->(value) { where(page: value) }
      scope :per_page, ->(value) { where(per_page: value) }
    end

    module ClassMethods
      # Overrides the method included by Spyke::Scoping to return paginated relations.
      def all
        current_scope || Relation.new(self, uri: uri)
      end
    end

    class Relation < Spyke::Relation
      HEADERS.each_key do |symbol|
        define_method(symbol) do
          find_some.metadata[METADATA_KEY][symbol]
        end
      end

      def first_page?
        current_page == 1
      end

      def next_page
        current_page + 1
      end

      def last_page?
        current_page >= total_pages
      end

      def supports_pagination?
        current_page.present?
      end

      # Unlike the default implementation in Spyke, this version of #each is recursive
      # and will repeatedly paginate through the remote API until it runs out of
      # records.
      #
      # To avoid this behaviour, you can ask for a Lazy enumerator to take just the
      # records you need, e.g.:
      #   User.all.lazy.take(3).to_a
      #   #=> [.., .., ..]
      def each(&block)
        return to_enum(:each) unless block_given?

        find_some.each(&block)
        return if !supports_pagination? || last_page?

        puts "There are #{total_pages} pages, I will load more pages automatically" if first_page?
        clone.page(next_page).each(&block)
      end

      def clone
        # We use cloning when fetching a second page using the same scope/query, however
        # we want to clear any loaded records from @find_some before doing so.
        super.tap { |obj| obj.instance_variable_set(:@find_some, nil) }
      end
    end
  end
end
