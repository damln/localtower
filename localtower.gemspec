$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "localtower/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "localtower"
  s.version = Localtower::VERSION
  s.authors = ["Damian Le Nouaille Diez"]
  s.email = ["damlenouaille@gmail.com"]
  s.homepage = "https://github.com/damln/localtower"
  s.summary = "Manage your models, relations, and migrations from a simple UI."
  s.description = ""

  s.files = Dir["{app,config,db,lib,public}/**/*"] + ["Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 5.2.0"
  s.add_dependency "thor", ">= 0.18.1"
  s.add_dependency "active_link_to", ">= 1.0.4"

  s.add_development_dependency "pg", ">= 0.21.0"
  s.add_development_dependency "rspec-rails", ">= 3.6.0"
  s.add_development_dependency "factory_bot_rails", ">= 6.2.0"
end
