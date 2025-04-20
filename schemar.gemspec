# frozen_string_literal: true

require_relative "lib/schemar/version"

Gem::Specification.new do |spec|
  spec.name = "schemar"
  spec.version = Schemar::VERSION
  spec.authors = ["Toshiaki Seino"]
  spec.email = ["st12318@gmail.com"]

  spec.summary = "Generate OpenAPI schema from Ruby models"
  spec.description = "Schemar is a Ruby gem that generates OpenAPI schema from Ruby models. It provides a simple DSL to define model attributes and enums, and generates OpenAPI 3.0.0 compatible schema in YAML or JSON format."
  spec.homepage = "https://github.com/toshiemon18/schemar"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/toshiemon18/schemar"
  spec.metadata["changelog_uri"] = "https://github.com/toshiemon18/schemar/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "bin"
  spec.executables = ["schemar"]
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "thor", "~> 1.3"

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "rubocop-rake", "~> 0.6"
  spec.add_development_dependency "rubocop-rspec", "~> 3.6"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
