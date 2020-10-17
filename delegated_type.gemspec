require_relative 'lib/delegated_type/version'

Gem::Specification.new do |spec|
  spec.name          = "delegated_type"
  spec.version       = DelegatedType::VERSION
  spec.authors       = ["Roberto Miranda Altamar"]
  spec.email         = ["rjmaltamar@gmail.com"]

  spec.summary       = %q{delegated_type is an alternative to single-table inheritance for representing class hierarchies. Backport of ActiveRecord::DelegatedType 6.1 to AR 5.x and 6.x}
  spec.description   = %q{The second type of model inheritance supported from rails 6.1, delegated type, where each sub-model has its own database table and can be queried and created individually.}
  spec.homepage      = "https://github.com/robertomiranda/delegated_type"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", [">= 5.0",  "< 6.1"]

  spec.add_development_dependency 'sqlite3'
end
