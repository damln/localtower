#
# @see https://github.com/rails/rails/blob/main/activerecord/lib/active_record/migration.rb
# @see https://github.com/rails/rails/blob/main/activerecord/lib/active_record/migration/command_recorder.rb
# @see https://api.rubyonrails.org/v7.2.1/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html
#
module Localtower
  module Generators
    class ThorGeneratorMigration < Thor
      SPACE_PADDING = "    "

      include Thor::Base
      include Thor::Actions

      no_commands do
        def migration_add_column(data)
          raise "No table name provided" if data['table_name'].blank?
          raise "No attribute name provided" if data['column_name'].blank?

          # Special case for array
          if %w[array].include?(data["column_type"])
            line  = "#{SPACE_PADDING}add_column :#{data['table_name']}, :#{data['column_name']}, :string"
            line << ", default: #{data['default']}" if data['default'].present?
            line << ", array: true"
          else
            line  = "#{SPACE_PADDING}add_column :#{data['table_name']}, :#{data['column_name']}, :#{data['column_type']}"
            line << ", default: #{data['default']}" if data['default'].present?
            line << ", null: false" if data['nullable'] == false
          end

          line << "\n"

          inject_in_migration(file, line)

          if data["index"].present?
            migration_add_index_to_column(data)
          end
        end

        def migration_remove_column(data)
          raise "No table name provided" if data['table_name'].blank?
          raise "No attribute name provided" if data['column_name'].blank?

          line = "#{SPACE_PADDING}remove_column :#{data['table_name']}, :#{data['column_name']}\n"

          inject_in_migration(file, line)
        end

        def migration_rename_column(data)
          raise "No table name provided" if data['table_name'].blank?
          raise "No attribute name provided" if data['column_name'].blank?
          raise "No new attribute name provided" if data['new_column_name'].blank?

          line = "#{SPACE_PADDING}rename_column :#{data['table_name']}, :#{data['column_name']}, :#{data['new_column_name']}\n"

          inject_in_migration(file, line)
        end

        def migration_change_column_type(data)
          raise "No table name provided" if data['table_name'].blank?
          raise "No attribute name provided" if data['column_name'].blank?
          raise "No new attribute type provided" if data['new_column_type'].blank?

          line = "#{SPACE_PADDING}change_column :#{data['table_name']}, :#{data['column_name']}, :#{data['new_column_type']}\n"

          inject_in_migration(file, line)
        end

        def migration_add_index_to_column(data)
          raise "No table name provided" if data['table_name'].blank?
          raise "No attribute name provided" if data['column_name'].blank?
          raise "No index provided" if data['index'].blank?

          line = "#{SPACE_PADDING}add_index :#{data['table_name']}, :#{data['column_name']}\n"

          inject_in_migration(file, line)

          # Custom options:
          params = [data]
                    .select { |attr| attr["index"].present? }
                    .each_with_object([]) do |attr, arr|
            arr << Hash[attr['column_name'],
                        { "using" => attr['index'], "algorithm" => attr['index_algorithm'], "unique" => attr['unique'] }]
          end
          ::Localtower::Generators::ServiceObjects::InsertIndexes.new(params).call
        end

        def migration_remove_index_to_column(data)
          raise "No table name provided" if data['table_name'].blank?
          raise "No index_name provided" if data['index_name'].blank?

          line = "#{SPACE_PADDING}remove_index :#{data['table_name']}, name: :#{data['index_name']}\n"

          inject_in_migration(file, line)
        end

        def migration_belongs_to(data)
          raise "No table name provided" if data['table_name'].blank?
          raise "No attribute name provided" if data['column_name'].blank?

          line = "#{SPACE_PADDING}add_reference :#{data['table_name']}, :#{data['column_name']}"

          line << ", foreign_key: true" if data['foreign_key'].present?
          line << ", index: true"
          line << "\n"

          inject_in_migration(file, line)
        end

        def migration_drop_table(data)
          raise "No table name provided" if data['table_name'].blank?

          line = "#{SPACE_PADDING}drop_table :#{data['table_name']}\n"

          inject_in_migration(file, line)
        end

        private

        def inject_in_migration(file, line)
          inject_into_file(file, line, before: "  end\nend")
        end

        def file
          Localtower::Tools.last_migration_pending
        end
      end
    end

    class Migration
      TYPES = [
        {
          name: "string",
          example: "'foo'",
        },
        {
          name: "text",
          example: "'long foo'",
        },
        {
          name: "datetime",
          example: "2024-07-22 12:28:31.487318",
        },
        {
          name: "date",
          example: "2024-09-24",
        },
        {
          name: "uuid",
          example: "'860f5e00-0000-0000-0000-000000000000'",
        },
        {
          name: "integer",
          example: "123",
        },
        {
          name: "bigint",
          example: "123",
        },
        {
          name: "float",
          example: "30.12",
        },
        {
          name: "numeric",
          example: "30.12",
        },
        {
          name: "decimal",
          example: "30.12",
        },
        {
          name: "json",
          example: "{\"foo\": \"bar\"}",
        },
        {
          name: "jsonb",
          example: "{\"foo\": \"bar\"}",
        },
        {
          name: "binary",
          example: "01010001",
        },
        {
          name: "boolean",
          example: "true/false",
        },
        {
          name: "array",
          example: "[1, 2, 3]",
        },
        {
          name: "blob",
          example: "x3F7F2A9",
        },
        {
          name: "references",
          example: "MyModel",
        }
      ]

      ACTIONS = [
        {
          name: "add_column",
          label: "Add column",
          example: "add_column :users, :name, :string",
        },
        {
          name: "add_index_to_column",
          label: "Add index",
          example: "add_index :users, :name",
        },
        {
          name: "belongs_to",
          label: "Add reference",
          example: "add_reference :posts, :user",
        },
        {
          name: "remove_index_to_column",
          label: "Remove index",
          example: "remove_index :users, :name",
        },
        {
          name: "remove_column",
          label: "Remove column",
          example: "remove_column :users, :name",
        },
        {
          name: "change_column_type",
          label: "Change column type",
          example: "change_column :users, :name, :string",
        },
        {
          name: "rename_column",
          label: "Rename column",
          example: "rename_column :users, :name, :new_name",
        },
        {
          name: "drop_table",
          label: "Drop table",
          example: "drop_table :users",
        }
      ]

      # @opts =
      def initialize(migrations, migration_name = nil)
        @thor = ThorGeneratorMigration.new

        # stringify keys:
        @migrations = JSON[migrations.to_json]
        @migration_name = migration_name
      end

      # const DEFAULT_LINE = {
      #   model_name: MODELS[0] ? MODELS[0].value : '',
      #   table_name: MODELS[0] ? MODELS[0].table_name : '',
      #   action_name: 'add_column',
      #   column_type: 'string',
      #   column_name: '',
      #   new_column_name: '',
      #   new_column_type: '',
      #   default: '',
      #   unique: false,
      #   foreign_key: false,
      #   index: '',
      #   index_algorithm: 'default',
      #   index_name: '',
      #   nullable: true
      # };

      def run
        if Localtower::Tools.pending_migrations.any?
          # raise "There is a pending migration. You can't generate a migration until the pending migration is committed."
        else
          migration_name_final = if @migration_name.present?
            @migration_name
          else
            action_names = migrations.map { |line| line['action_name'].camelize }.uniq.take(1).join
            model_names = migrations.map { |line| line['model_name'].camelize }.uniq.take(2).join
            column_names = migrations.map { |line| (line['column_name'].presence || "").camelize }.uniq.take(2).join

            "#{action_names}#{column_names}For#{model_names}"
          end

          ::Localtower::Tools.perform_migration(migration_name_final)
        end

        migrations.each do |action_line|
          next if action_line['action_name'].blank?

          # action_line['table_name'] = action_line['model_name'].pluralize.underscore

          proc_var = {
            'add_column' => -> { thor.migration_add_column(action_line) },
            'remove_column' => -> { thor.migration_remove_column(action_line) },
            'rename_column' => -> { thor.migration_rename_column(action_line) },
            'change_column_type' => -> { thor.migration_change_column_type(action_line) },
            'add_index_to_column' => -> { thor.migration_add_index_to_column(action_line) },
            'belongs_to' => -> { thor.migration_belongs_to(action_line) },
            'remove_index_to_column' => -> { thor.migration_remove_index_to_column(action_line) },
            'drop_table' => -> { thor.migration_drop_table(action_line) }
          }[action_line['action_name']]

          raise "No proc found for action_name #{action_line['action_name']}" unless proc_var

          proc_var.call
        end
      end

      attr_reader :thor, :migrations
    end
  end
end
