# frozen_string_literal: true

require_relative "lib/zaikio/client/helpers/version"

Gem::Specification.new do |spec|
  spec.name          = "zaikio-client-helpers"
  spec.version       = Zaikio::Client::Helpers::VERSION
  spec.authors       = ["Zaikio GMBH"]
  spec.email         = ["suppoert@zaikio.com"]

  spec.summary       = "Small meta-gem with middleware and tools for working with Zaikio APIs"
  spec.homepage      = "https://github.com/zaikio/zaikio-client-helpers"
  spec.license       = "MIT"

  spec.metadata["changelog_uri"] = "https://github.com/zaikio/zaikio-client-helpers/blob/main/CHANGELOG.md"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md",
                   "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday"
  spec.add_dependency "multi_json"
  spec.add_dependency "spyke"

  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
end
