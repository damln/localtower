namespace :db do
  desc "Reset the database"
  task localtower_reset: :environment do
    puts "Custom reset."

    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end

    models = Dir["#{Rails.root}/app/models/**/*.rb"].reject { |file_name| file_name['application_record.rb']}

    FileUtils.rm_rf(models)
    FileUtils.rm_rf(Dir["#{Rails.root}/db/migrate/*"])
    FileUtils.rm_rf(Dir["#{Rails.root}/db/schema.rb"])
  end
end
