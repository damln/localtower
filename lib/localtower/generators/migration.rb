module Localtower
  module Generators
    class ThorGeneratorMigration < Thor
      include Thor::Base
      include Thor::Actions

      no_commands do
        def migration_add_column(data)
          # Special case for array
          if %w[array].include?(data["column_type"])
            line  = "    add_column :#{data['table_name']}, :#{data['column']}, :string"
            line << ", default: []"
            line << ", array: true"
          else
            line  = "    add_column :#{data['table_name']}, :#{data['column']}, :#{data['column_type']}"
            line << ", default: #{data['default']}" if data['default'].present?
            line << ", null: false" if data['nullable'] == false
          end

          line << "\n"

          inject_in_migration(file, line)
        end

        def migration_remove_column(data)
          line = "    remove_column :#{data['table_name']}, :#{data['column']}\n"

          inject_in_migration(file, line)
        end

        def migration_rename_column(data)
          line = "    rename_column :#{data['table_name']}, :#{data['column']}, :#{data['new_column_name']}\n"

          inject_in_migration(file, line)
        end

        def migration_change_column_type(data)
          line = "    change_column :#{data['table_name']}, :#{data['column']}, :#{data['new_column_type']}\n"

          inject_in_migration(file, line)
        end

        def migration_add_index_to_column(data)
          line = "    add_index :#{data['table_name']}, :#{data['column']}\n"

          inject_in_migration(file, line)

          # Custom options:
          params = [data]
          .select { |attr| attr.dig('index', 'using').present? }
          .reject { |attr| attr.dig('index', 'using') == 'none' }
          .each_with_object([]) do |attr, arr|
            arr << Hash[attr['column'], attr['index']]
          end
          ::Localtower::Generators::ServiceObjects::InsertIndexes.new(params).call
        end

        def migration_remove_index_to_column(data)
          line = "    remove_index :#{data['table_name']}, :#{data['column']}\n"

          inject_in_migration(file, line)
        end

        def migration_belongs_to(data)
          line = "    add_reference :#{data['table_name']}, :#{data['column']}, foreign_key: true, index: true\n"

          inject_in_migration(file, line)

          file = "#{Rails.root}/app/models/#{data['table_name'].underscore.singularize}.rb"
          after = /class #{data["table_name"].camelize.singularize} < ApplicationRecord\n/
          line1 = "  # belongs_to :#{data['column'].singularize.underscore}\n"

          if File.exist?(file)
            ::Localtower::Tools::ThorTools.new.insert_after_word(file, after, line1)
          end

          file = "#{Rails.root}/app/models/#{data['column'].underscore.singularize}.rb"
          after = /class #{data["column"].camelize.singularize} < ApplicationRecord\n/
          line1 = "  # has_many :#{data['table_name'].pluralize.underscore}\n"

          if File.exist?(file)
            ::Localtower::Tools::ThorTools.new.insert_after_word(file, after, line1)
          end
        end

        def migration_drop_table(data)
          line = "    drop_table :#{data['table_name']}\n"

          inject_in_migration(file, line)
        end

        private

        def inject_in_migration(file, line)
          inject_into_file(file, line, before: "  end\nend")
        end

        def file
          Localtower::Tools.last_migration
        end
      end
    end

    class Migration
      TYPES = %w[string datetime date text uuid integer float json jsonb decimal binary boolean array references].freeze
      ACTIONS = %w[
        add_column
        add_index_to_column
        remove_index_to_column
        belongs_to
        remove_column
        change_column_type
        rename_column
        drop_table
      ].freeze

      # @opts =
      def initialize(migrations)
        @thor = ThorGeneratorMigration.new
        @migrations = JSON[migrations.to_json]
      end

      def run
        model_names = migrations.map { |line| line['table_name'].camelize }.uniq.join

        cmd = "Change#{model_names}At#{Time.now.to_i}"
        ::Localtower::Tools.perform_migration(cmd)

        migrations.each do |action_line|
          next if action_line['action'].blank?

          {
            'add_column' => -> { add_column(action_line) },
            'remove_column' => -> { remove_column(action_line) },
            'rename_column' => -> { rename_column(action_line) },
            'change_column_type' => -> { change_column_type(action_line) },
            'add_index_to_column' => -> { add_index_to_column(action_line) },
            'belongs_to' => -> { belongs_to(action_line) },
            'remove_index_to_column' => -> { remove_index_to_column(action_line) },
            'drop_table' => -> { drop_table(action_line) }
          }[action_line['action']].call
        end
      end

      private

      attr_reader :migrations

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

      def drop_table(data)
        @thor.migration_drop_table(data)
      end
    end
  end
end
