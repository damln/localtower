module Localtower
  class Status
    def run
      files = Dir["#{Rails.root}/db/migrate/*.rb"].sort.reverse
      db_migrations = begin
        ActiveRecord::Base.connection.execute("select * from schema_migrations;")
      rescue => e
        []
      end

      db_migrations = db_migrations.map { |e| e["version"].to_s }

      files.map do |file_full_path|
        name = file_full_path.split("/")[-1] # add_email_to_user.rb
        time = name.split("_")[0] # 201203890987
        status = db_migrations.include?(time) ? :done : :todo
        content = File.open(file_full_path).read

        {
          "file_full_path" => file_full_path,
          "name" => name,
          "time" => time.to_i,
          "status" => status,
          "content" => content
        }
      end
    end
  end
end
