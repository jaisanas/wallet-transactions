# frozen_string_literal: true

require_relative "lib/latest_price_stock/version"

Gem::Specification.new do |spec|
  spec.name = "latest_price_stock"
  spec.version = "1.0.0"
  spec.authors = "Jais Anasrulloh Jafari"
  spec.email = "jaisanas2@gmail.com"

  spec.summary = "Simple api library to get latest price stock"
  spec.description = "Simple api library to get latest price stock"
  spec.homepage = "Simple api library to get latest price stock"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://github.com/jaisanas/wallet-transactions/tree/main/lib/"

  spec.metadata["homepage_uri"] = "https://github.com/jaisanas/wallet-transactions/tree/main/lib/"
  spec.metadata["source_code_uri"] = "https://github.com/jaisanas/wallet-transactions/tree/main/lib/"
  spec.metadata["changelog_uri"] = "https://github.com/jaisanas/wallet-transactions/tree/main/lib/"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
