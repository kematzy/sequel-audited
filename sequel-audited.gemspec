# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sequel/audited/version"

Gem::Specification.new do |spec|
  spec.name          = "sequel-audited"
  spec.version       = Sequel::Audited::VERSION
  spec.authors       = ["Kematzy"]
  spec.email         = ["kematzy@gmail.com"]

  spec.summary       = "A Sequel plugin that logs changes made to an audited model, including who created, updated and destroyed the record, and what was changed and when the change was made"
  spec.description   = "A Sequel plugin that logs changes made to an audited model, including who created, updated and destroyed the record, and what was changed and when the change was made. This plugin provides model auditing (a.k.a: record versioning) for DB scenarios when DB triggers are not possible. (ie: on a web app on Heroku)."
  spec.homepage      = "https://github.com/kematzy/sequel-audited"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sequel", "~> 5.3"
  # spec.add_runtime_dependency "pg" #, "~> 4.2"

  spec.add_development_dependency "bundler" #, "~> 1.11"
  spec.add_development_dependency "rake" #, "~> 10.0"
  spec.add_development_dependency "minitest", ">= 5.7.0"
  spec.add_development_dependency "minitest-rg"
  spec.add_development_dependency "minitest-assert_errors"
  spec.add_development_dependency "minitest-hooks"
  spec.add_development_dependency "minitest-sequel", ">= 0.3.2"

  spec.add_development_dependency "pg"
  spec.add_development_dependency "sqlite3"

  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "dotenv"

end
