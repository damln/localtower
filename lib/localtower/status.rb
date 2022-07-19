module Localtower
  class Status
    def run
      files = Dir["#{Rails.root}/db/migrate/*.rb"].sort.reverse

      names = files.map do |file_full_path|
        file_full_path.split("/")[-1]
      end

      db_migrations = ActiveRecord::Base.connection.execute("select * from schema_migrations;").map { |e| e["version"].to_s }.sort.reverse

      names.map do |name|
        time = name.split("_")[0]
        status = db_migrations.include?(time) ? :done : :todo

        {
          "name" => name,
          "time" => time,
          "status" => status,
        }
      end
    end
  end
end
