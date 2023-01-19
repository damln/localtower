module Localtower
  module Generators
    module ServiceObjects
      class InsertArray
        def initialize(attributes)
          @attributes = attributes
        end

        def call
          attributes.each do |attribute|
            line_str = File.read(Localtower::Tools.last_migration).match(/((.*)t\.string :#{attribute})/)[0]
            content = File.read(Localtower::Tools.last_migration).gsub(line_str, "#{line_str}, array: true")
            File.write(Localtower::Tools.last_migration, content)
          end
        end

        private

        attr_reader :attributes
      end
    end
  end
end
