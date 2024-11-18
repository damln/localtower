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

        DEFAULT_VALUES = {
          'NULL' => { value: '', label: 'NULL', example: 'NULL' },
          'EMPTY_STRING' => { value: "''", label: 'Empty string', example: "''" },
          'NOW_DATETIME' => { value: "'now()'", label: 'Current datetime', example: 'now()' },
          'NOW_DATE' => { value: "'now()'", label: 'Current date', example: 'now()' },
          'ZERO' => { value: "0", label: 'Zero', example: '0' },
          'JSON' => { value: "{}", label: 'Empty JSON', example: '{}' }
        }

        DEFAULTS_BY_TYPE = {
          string: [
            DEFAULT_VALUES['NULL'],
            DEFAULT_VALUES['EMPTY_STRING']
          ],
          text: [
            DEFAULT_VALUES['NULL'],
            DEFAULT_VALUES['EMPTY_STRING']
          ],
          datetime: [
            DEFAULT_VALUES['NULL'],
            DEFAULT_VALUES['NOW_DATETIME']
          ],
          date: [
            DEFAULT_VALUES['NULL'],
            DEFAULT_VALUES['NOW_DATE']
          ],
          uuid: [
            DEFAULT_VALUES['NULL']
          ],
          integer: [
            DEFAULT_VALUES['NULL'],
            DEFAULT_VALUES['ZERO']
          ],
          bigint: [
            DEFAULT_VALUES['NULL'],
            DEFAULT_VALUES['ZERO']
          ],
          float: [
            DEFAULT_VALUES['NULL'],
            DEFAULT_VALUES['ZERO']
          ],
          numeric: [
            DEFAULT_VALUES['NULL'],
            DEFAULT_VALUES['ZERO']
          ],
          decimal: [
            DEFAULT_VALUES['NULL'],
            DEFAULT_VALUES['ZERO']
          ],
          json: [
            DEFAULT_VALUES['NULL'],
            DEFAULT_VALUES['JSON']
          ],
          jsonb: [
            DEFAULT_VALUES['NULL'],
            DEFAULT_VALUES['JSON']
          ],
          boolean: [
            DEFAULT_VALUES['NULL'],
            { value: 'true', label: 'True', example: 'true' },
            { value: 'false', label: 'False', example: 'false' }
          ],
          array: [
            DEFAULT_VALUES['NULL'],
            { value: '[]', label: 'Empty array', example: '[]' }
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
