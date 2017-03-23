module Localtower
  module Generators
    module ServiceObjects
      class InsertDefaults

        def initialize(attributes)
          @attributes = attributes
        end

        def call
          insert_defaults
        end

        private

        attr_reader :attributes

        def insert_defaults
          attributes.each do |attribute|
            attribute.each do |attr_key, attr_value|
              process_migration_file(attr_key, attr_value)
            end
          end
          build_file(file_lines)
        end

        def process_migration_file(attr_key, attr_value)
          file_lines.map do |line|
            attach_default_value(line, attr_key, attr_value)
          end
        end

        def attach_default_value(line, attr_key, attr_value)
          if table_attribute_line?(line) and line.include? attr_key
            build_line(line, attr_value)
          else
            line
          end
        end

        def build_file(lines)
          File.open(latest_migration, 'w') { |f| f.puts lines }
        end

        def build_line(line, attr_value)
          line.gsub!("\n", "") << ", default: " << "#{attr_value}" << "\n"
        end

        def latest_migration
          @latest_migration ||= Dir["#{Rails.root}/db/migrate/*"].last
        end

        def file_lines
          @file_lines ||= File.readlines(latest_migration)
        end

        def table_attribute_line?(line)
          line.squish.start_with? "t."
        end

      end
    end
  end
end
