module Localtower
  module Generators
    module ServiceObjects
      class InsertArray
        def initialize(attributes)
          @attributes = attributes
        end

        def call
          attributes.each do |attribute|
            line_str = Localtower::Tools.line_for_attribute(attribute)[0]
            if line_str.present?
              content = File.read(Localtower::Tools.last_migration_pending).gsub(line_str, "#{line_str}, array: true")
              File.write(Localtower::Tools.last_migration_pending, content)
            end
          end
        end

        private

        attr_reader :attributes
      end
    end
  end
end
