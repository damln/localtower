$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "localtower/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "localtower"
  s.version     = Localtower::VERSION
  s.authors     = ["Damian Le Nouaille"]
  s.email       = ["dam@dln.name"]
  s.homepage    = "https://github.com/damln/localtower"
  s.summary     = "Manage your models, relations, and migrations from a simple UI."
  s.description = ""

  s.files = Dir["{app,config,db,lib,public}/**/*"] + ["Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 5.0.0"
  # s.add_dependency "rails", ">= 4.2.0"
  s.add_dependency "thor"
  s.add_dependency "active_link_to"
  s.add_dependency "rubyzip"
  s.add_dependency "pg"
  s.add_dependency "sqlite3"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "guard-rspec"
  # s.add_development_dependency "zeus"
  # s.add_development_dependency "simplecov"
end
