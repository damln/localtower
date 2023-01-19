module Localtower
  module Generators
    module ServiceObjects
      class InsertDefaults
        DEFAULTS = {
          '(no default value)' => '',
          "empty string ('')" => "''",
          'zero (0)' => '0',
          'true' => 'true',
          'false' => 'false',
          'empty array ([])' => '[]',
          'empty hash ({})' => '{}',
          'nil' => 'nil',
        }

        def initialize(attributes)
          @attributes = attributes
        end

        def call
          attributes.each do |attribute|
            attribute.each do |attr_key, attr_value|
              line_str = File.read(Localtower::Tools.last_migration).match(/((.*)t\.(.*)\:#{attr_key})/)[0]
              content = File.read(Localtower::Tools.last_migration).gsub(line_str, "#{line_str}, default: #{attr_value}")
              File.write(Localtower::Tools.last_migration, content)
            end
          end
        end

        private

        attr_reader :attributes
      end
    end
  end
end
