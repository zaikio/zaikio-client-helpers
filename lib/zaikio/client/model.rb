require_relative "helpers/pagination"

module Zaikio
  module Client
    class Model < Spyke::Base
      include Helpers::Pagination
    end
  end
end
