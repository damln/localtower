def clean_files
  ::ActiveRecord::Base.connection.tables.each do |table|
    cmd = "DROP TABLE if exists #{table.upcase} cascade;"
    ::ActiveRecord::Base.connection.execute(cmd)
  end

  # remove Schema:
  Dir["#{Rails.root}/db/migrate/*"].each { |migration_file| File.delete(migration_file) }

  content_schema = """
ActiveRecord::Schema.define(version: 0) do
end
  """

  File.open("#{Rails.root}/db/schema.rb", "w") do |f|
    f.write(content_schema)
  end

  Dir["#{Rails.root}/app/models/**/*.*"]
  .reject { |file_name| file_name['application_record.rb']}
  .each { |model_file| File.delete(model_file) }
end

def migration_files
  Dir["#{Rails.root}/db/migrate/*"]
end

def last_migration
  migration_files.sort.last
end

def word_in_file?(file, word_or_exp)
  File.readlines(file).grep(word_or_exp).size > 0
end

#============================
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rspec/rails'
require 'factory_bot'

Rails.application.eager_load!
Rails.backtrace_cleaner.remove_silencers!

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = true

  config.order = 123

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.before(:each) do
    clean_files
  end

  config.after(:all) do
    clean_files
  end
end
