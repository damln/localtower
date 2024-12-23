module Localtower
  class Tools
    class ThorTools < Thor
      include Thor::Base
      include Thor::Actions

      no_commands do
        def insert_after_word(file, word, str)
          inject_into_file file, str, after: word
        end
      end
    end

    class << self
      def force_reload!
        app_folders = Dir["#{Rails.root}/app/models/**/*.rb"]
        all_folders = (app_folders).flatten

        all_folders.each do |file|
          begin
            require file
          rescue Exception => e
            puts "Error loading: #{file}, #{e.message}"
          end
        end
      end

      def models
        self.force_reload!

        root_klass = defined?(ApplicationRecord) ? ApplicationRecord : ActiveRecord::Base

        root_klass.subclasses - [ActiveRecord::SchemaMigration]
      end

      def models_presented
        self.force_reload!

        list = []

        self.models.each do |model|
          attributes_list = []

          # Using this trick because the model might exist but not migrated yet
          columns_hash = begin
            model.columns_hash
          rescue
            []
          end

          columns_hash.each do |_k, v|

            belongs_to = nil

            if v.name.strip =~ /\_id$/
              belongs_to = v.name.strip.gsub(/_id$/, "").singularize.camelize
            end

            attributes_list << {
              'name' => v.name.strip,
              'type' => v.sql_type.strip,
              'belongs_to' => belongs_to,
              'type_clean' => v.sql_type.split(' ')[0].strip,
              'primary' => (v.respond_to?(:primary) ? v.primary : false),
              'index' => self.indexes_for_model_and_attribute(model, v.name),
            }
          end

          list << {
            name: model.name,
            underscore: model.name.underscore,
            table_name: model.table_name,
            attributes_list: attributes_list,
          }
        end

        list
      end

      def indexes_for_model(model)
        indexes = ActiveRecord::Base.connection.indexes(model.table_name)
        return [] if indexes.empty?

        max_size = indexes.map { |index| index.name.size }.max + 1

        list = []

        indexes.each do |index|
          list << {
            unique: index.unique,
            name: index.name,
            columns: index.columns,
            max_size: max_size
          }
        end

        list
      end

      def indexes_for_model_and_attribute(model, column_name)
        indexes = self.indexes_for_model(model)

        list = []
        done = []

        indexes.each do |index|
          conditions = index[:columns].include?(column_name.to_s) and not done.include?(index[:name])
          next unless conditions
          infos = {
            unique: index[:unique],
            name: index[:name],
            columns: index[:columns],
            max_size: index[:max_size]
          }

          done << column_name
          list << infos
        end

        list
      end

      def all_columns
        models.map do |model|
          columns = begin
            model.columns
          rescue
            []
          end

          columns.map { |column| column.name }.flatten
        end.flatten.uniq.sort
      end

      def perform_migration(str)
        self.perform_cmd("rails g migration #{str}")
      end

      def perform_cmd(cmd_str)
        self.perform_raw_cmd("bundle exec #{cmd_str}")
      end

      def perform_raw_cmd(cmd_str)
        root_dir = ::Rails.root

        cmd = "cd \"#{root_dir}\" && #{cmd_str}"
        cmd = cmd.strip

        self.log("DOING...: #{cmd}")

        before_sec = Time.now
        output = `#{cmd}`

        after_sec = Time.now
        self.log(output)

        sec = after_sec - before_sec

        self.log("DONE: #{cmd} in #{sec} sec")
        output
      end

      def log(str)
        self.create_log
        log_str = "[#{Time.now}] - #{str}\n"
        File.open(self.log_file, 'a') { |f| f.write(log_str) }
      end

      def log_file
        @log_file ||= Rails.root.join('log', 'localtower.log')
      end

      def last_migration_pending
        last_not_run_migration = Localtower::Status.new.run.select {|i| i['status'] == :todo}.sort { |a, b| a['time'] <=> b['time'] }.last

        return nil if last_not_run_migration.blank?
        return nil unless File.exist?(last_not_run_migration["file_full_path"])


        last_not_run_migration["file_full_path"]
      end

      def pending_migrations
        Localtower::Status.new.run.select {|i| i['status'] == :todo}
      end

      def line_for_attribute(attribute)
        (File.read(last_migration_pending).match(/^\s*t\.(.*)\s*:#{attribute}.*$/) || [])
      end

      # PRIVATE ==============
      def create_log
        return nil if File.exist?(self.log_file)

        File.open(self.log_file, 'w') { |f| f.write('') }
      end
    end
  end
end
