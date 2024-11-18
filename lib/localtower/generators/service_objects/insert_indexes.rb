module Localtower
  module Generators
    module ServiceObjects
      class InsertIndexes
        USING = [
          {
            label: 'default',
            name: 'default',
            example: 'using: :btree'
          },
          {
            name: 'hash',
            example: 'using: :hash'
          },
          {
            name: 'gin',
            example: 'using: :gin'
          },
          {
            name: 'gist',
            example: 'using: :gist'
          },
          {
            name: 'spgist',
            example: 'using: :spgist'
          },
          {
            name: 'brin',
            example: 'using: :brin'
          },
          {
            name: 'bloom',
            example: 'using: :bloom'
          }
        ]

        UNIQUE = [
          false,
          true
        ]

        ALGO = %w[
          concurrently
        ]

        def initialize(attributes)
          @attributes = attributes
        end

        def call
          attributes.each do |attribute|
            attribute.each do |attr_key, options|
              line_str_original = File.read(Localtower::Tools.last_migration_pending).match(/((.*)add_index :(.*), :#{attr_key})/)[0]
              line_str = line_str_original.clone

              line_str = inser_using(line_str, options)
              line_str = inser_algorithm(line_str, options)
              line_str = inser_unique(line_str, options)

              content = File.read(Localtower::Tools.last_migration_pending).gsub(line_str_original, line_str)
              content = add_disable_ddl_transaction(content, options)

              File.write(Localtower::Tools.last_migration_pending, content)
            end
          end
        end

        private

        attr_reader :attributes

        def inser_using(line_str, options)
          return line_str if options['using'].blank?
          return line_str if options['using'] == 'default'

          line_str << ", using: :#{options['using']}"
        end

        def inser_unique(line_str, options)
          return line_str if options['unique'].blank?

          line_str << ", unique: true"
        end

        def inser_algorithm(line_str, options)
          return line_str if options['algorithm'].blank?
          return line_str if options['algorithm'] == 'default'

          line_str << ", algorithm: :#{options['algorithm']}"
        end

        def add_disable_ddl_transaction(content, options)
          return content if options['algorithm'] != 'concurrently'

          # Add disable_ddl_transaction! if the algorythm is 'concurrently'
          content = content.gsub(/^class (.*)$/, "class \\1\n  disable_ddl_transaction!\n") if content['disable_ddl_transaction'].blank?

          content
        end
      end
    end
  end
end
