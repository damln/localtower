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

        DEFAULTS_BY_TYPE = {
          string: [
            { value: '', label: 'null' },
            { value: "''", label: 'Empty string ("")' },
          ],
          text: [
            { value: '', label: 'null' },
            { value: "''", label: 'Empty string ("")' },
          ],
          datetime: [
            { value: '', label: 'null' },
            { value: 'now()', label: 'Current datetime (now())' },
          ],
          date: [
            { value: '', label: 'null' },
            { value: 'now()', label: 'Current date (now())' },
          ],
          uuid: [
            { value: '', label: 'null' },
            { value: 'uuid_generate_v4()', label: 'Generate a UUID v4' },
          ],
          integer: [
            { value: '', label: 'null' },
            { value: '0', label: 'Zero (0)' },
          ],
          bigint: [
            { value: '', label: 'null' },
            { value: '0', label: 'Zero (0)' },
          ],
          float: [
            { value: '', label: 'null' },
            { value: '0', label: 'Zero (0)' },
          ],
          numeric: [
            { value: '', label: 'null' },
            { value: '0', label: 'Zero (0)' },
          ],
          decimal: [
            { value: '', label: 'null' },
            { value: '0', label: 'Zero (0)' },
          ],
          json: [
            { value: '', label: 'null' },
            { value: '{}', label: 'Empty JSON ({})' },
          ],
          jsonb: [
            { value: '', label: 'null' },
            { value: '{}', label: 'Empty JSON ({})' },
          ],
          boolean: [
            { value: '', label: 'null' },
            { value: 'true', label: 'true' },
            { value: 'false', label: 'false' },
          ],
          array: [
            { value: '', label: 'null' },
            { value: '[]', label: 'Empty array ([])' },
          ]
        }

        def initialize(attributes)
          @attributes = attributes
        end

        def call
          attributes.each do |attribute|
            attribute.each do |attr_key, attr_value|
              line_str = Localtower::Tools.line_for_attribute(attr_key)[0]
              if line_str.present?
                content = File.read(Localtower::Tools.last_migration_pending).gsub(line_str, "#{line_str}, default: #{attr_value}")
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
