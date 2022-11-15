module Localtower
  module Generators
    class ThorGeneratorMigration < Thor
      include Thor::Base
      include Thor::Actions

      no_commands do
        # data = {last_migration_file: "", column_type: "", table_name: "", column: "", nullable: true, index: true}
        def migration_add_column(data)
          file = data["last_migration_file"]

          # Special case for array
          if %w(array).include?(data["column_type"])
            line  = "    add_column :#{data['table_name']}, :#{data['column']}, :text"
            line << ", default: []"
            line << ", array: true"

            # Add an gin inde as well:
            line << "\n"
            line << "    add_index :#{data['table_name']}, :#{data['column']}, using: :gin"
          else
            line  = "    add_column :#{data['table_name']}, :#{data['column']}, :#{data['column_type']}"
            line << ", default: #{data['default']}" if data['default'].present?
            line << ", null: false" if not data['nullable']
            line << ", index: true" if data['index'] == true
          end

          line << "\n"

          inject_in_migration(file, line)
        end

        def migration_remove_column(data)
          file = data['last_migration_file']

          line = "    remove_column :#{data['table_name']}, :#{data['column']}\n"

          inject_in_migration(file, line)
        end

        def migration_rename_column(data)
          file = data['last_migration_file']

          line = "    rename_column :#{data['table_name']}, :#{data['column']}, :#{data['new_column_name']}\n"

          inject_in_migration(file, line)
        end

        def migration_change_column_type(data)
          file = data['last_migration_file']

          line = "    change_column :#{data['table_name']}, :#{data['column']}, :#{data['new_column_type']}\n"

          inject_in_migration(file, line)
        end

        def migration_add_index_to_column(data)
          file = data['last_migration_file']

          line = "    add_index :#{data["table_name"]}, :#{data["column"]}\n"

          inject_in_migration(file, line)
        end

        # def migration_add_index_to_column_combined(data)
        #   file = data["last_migration_file"]
        #   attr_names = data["column"].split(",")

        #   #     add_index :relationships, [:follower_id, :followed_id], unique: true
        #   line = "    add_index :#{data["table_name"]}, [#{attr_names.map { |i| ":#{i}"}.join(', ')}]"
        #   line << ", unique: true" if data["unique"]
        #   line << "\n"

        #   inject_in_migration(file, line)
        # end

        def migration_remove_index_to_column(data)
          file = data["last_migration_file"]

          line = "    remove_index :#{data["table_name"]}, :#{data["column"]}\n"

          inject_in_migration(file, line)
        end

        def migration_belongs_to(data)
          file = data["last_migration_file"]

          line = "    add_reference :#{data["table_name"]}, :#{data["column"]}, foreign_key: true, index: true\n"

          inject_in_migration(file, line)

          file = "#{Rails.root}/app/models/#{data["table_name"].underscore.singularize}.rb"
          after = /class #{data["table_name"].camelize.singularize} < ApplicationRecord\n/
          line1 = "  belongs_to :#{data["column"].singularize.underscore}\n"

          ::Localtower::Tools::ThorTools.new.insert_after_word(file, after, line1)


          file = "#{Rails.root}/app/models/#{data["column"].underscore.singularize}.rb"
          after = /class #{data["column"].camelize.singularize} < ApplicationRecord\n/
          line1 = "  has_many :#{data["table_name"].pluralize.underscore}\n"

          ::Localtower::Tools::ThorTools.new.insert_after_word(file, after, line1)
        end

        def migration_create_table(data)
          file = data["last_migration_file"]

          line = "    create_table :#{data["table_name"]}\n"

          inject_in_migration(file, line)
        end

        def migration_drop_table(data)
          file = data["last_migration_file"]

          line = "    drop_table :#{data["table_name"]}, force: :cascade\n"

          inject_in_migration(file, line)
        end

        private

        def inject_in_migration(file, line)
          inject_into_file(file, line,  after: "def change\n")
        end
      end
    end

    class Migration
      TYPES = %w(string datetime text uuid integer float json jsonb decimal binary boolean array references).freeze
      ACTIONS = [
        'add_column',
        'remove_column',
        'rename_column',
        'change_column_type',
        'add_index_to_column',
        'belongs_to',
        'remove_index_to_column',
        'drop_table',
      ].freeze

      DEFAULTS = [
        "true", "false", "nil", "0"
      ]

      # @opts =
      def initialize(opts)
        @thor = ThorGeneratorMigration.new
        @opts = JSON[opts.to_json]
      end

      # @opts['migrations'] = []
      # @opts['run_migrate'] = true
      def run
        model_names = @opts['migrations'].map { |line| line['table_name'].camelize }.join

        cmd = "Change#{model_names}#{@opts['migration_name']}At#{Time.now.to_i}"
        ::Localtower::Tools.perform_migration(cmd, true)

        @opts['migrations'].each do |action_line|
          next unless action_line['action'].present?

          # table_name = action_line['table_name']
          # column = action_line['column']
          # index = action_line['index']
          # default = action_line['default']
          # null = action_line['null']
          # unique = action_line['unique']
          # column_type = action_line['column_type']
          # new_column_type = action_line['new_column_type']
          # new_column_name = action_line['new_column_name']
          action_line["last_migration_file"] = last_migration_file

          {
            'add_column' => -> { add_column(action_line) },
            'remove_column' => -> { remove_column(action_line) },
            'rename_column' => -> { rename_column(action_line) },
            'change_column_type' => -> { change_column_type(action_line) },
            'add_index_to_column' => -> { add_index_to_column(action_line) },
            'belongs_to' => -> { belongs_to(action_line) },
            'remove_index_to_column' => -> { remove_index_to_column(action_line) },
            'create_table' => -> { create_table(action_line) },
            'drop_table' => -> { drop_table(action_line) }
            }[action_line['action'].downcase].call
        end

        if @opts['run_migrate']
          run_migration_or_nil
        end
      end

      #====================================
      def last_migration_file
        Dir["#{Rails.root}/db/migrate/*"].sort.last
      end

      # VALIDATION before continuing:
      private

      def add_column(data)
        @thor.migration_add_column(data)
      end

      def remove_column(data)
        @thor.migration_remove_column(data)
      end

      def rename_column(data)
        @thor.migration_rename_column(data)
      end

      def change_column_type(data)
        @thor.migration_change_column_type(data)
      end

      def add_index_to_column(data)
        @thor.migration_add_index_to_column(data)
      end

      def belongs_to(data)
        data["column"] = data["belongs_to"].underscore.singularize
        data['column_type'] = "references"

        @thor.migration_belongs_to(data)
      end

      def remove_index_to_column(data)
        @thor.migration_remove_index_to_column(data)
      end

      def create_table(data)
        @thor.migration_create_table(data)
      end

      def drop_table(data)
        @thor.migration_drop_table(data)
      end

      def run_migration_or_nil
        if last_migration_changed?
          ::Localtower::Tools.perform_cmd('rake db:migrate')
        else
          File.delete(last_migration_file)
          nil
        end
      end

      def last_migration_changed?
        File.readlines(last_migration_file).join != ~ /def change\n  end/
      end
    end
  end
end
