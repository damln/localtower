def clean_files
  ::Localtower::Tools.sql_drop_all_tables
  ::Localtower::Generators::Migration.new({}).remove_all_migrations
  Dir["#{Rails.root}/app/models/**/*.*"].each { |model_file| File.delete(model_file) }
end

def migration_files
  Dir["#{Rails.root}/db/migrate/*"]
end

def last_migration
  migration_files.sort.last
end

#============================
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rspec/rails'
require 'factory_girl'

Rails.application.eager_load!
Rails.backtrace_cleaner.remove_silencers!

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = true

  config.order = 123
  # config.order = 'random'

  config.before(:suite) do
    FactoryGirl.find_definitions
  end

  config.before(:all) do
    clean_files
  end

  config.after(:all) do
    clean_files
  end
end
