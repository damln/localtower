module Localtower
  module Generators
    module ServiceObjects
      class InsertForeignKeys
        def initialize(attributes)
          @attributes = attributes
        end

        def call
          attributes.each do |attribute|
            attribute.each do |attr_key, options|
              line_str = Localtower::Tools.line_for_attribute(attr_key)[0]
              if line_str.present?
                if options['foreign_key'].present?
                  if line_str['foreign_key: true']
                    content = File.read(Localtower::Tools.last_migration_pending)
                  else
                    content = File.read(Localtower::Tools.last_migration_pending).gsub(line_str, "#{line_str}, foreign_key: true")
                  end
                else
                  content = File.read(Localtower::Tools.last_migration_pending).gsub(line_str, line_str.gsub(', foreign_key: true', ''))
                end
                File.write(Localtower::Tools.last_migration_pending, content)
              end
            end
          end
        end

        private

        attr_reader :attributes
      end
    end
  end
end
