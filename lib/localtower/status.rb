module Localtower
  class Status
    def run
      files = Dir["#{Rails.root}/db/migrate/*.rb"].sort.reverse

      names = files.map do |file_full_path|
        file_full_path.split("/")[-1]
      end

      results = []

      migrations = ActiveRecord::Base.connection.execute("select * from schema_migrations;").map { |e| e["version"].to_s }.sort.reverse

      names.each do |name|
        number = name.split("_")[0]

        status = migrations.include?(number) ? 1 : 0

        data = {
          "name" => name,
          "status" => status,
        }

        results << data
      end

      results
    end
  end
end
