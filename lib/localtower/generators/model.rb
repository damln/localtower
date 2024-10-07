module Localtower
  module Generators
    class Model
      def initialize(opts)
        @opts = JSON[opts.to_json] # stringify keys
        @model_name = @opts['model_name']
        @attributes = @opts['attributes']

        raise "No model_name provided" if @model_name.blank?
        raise "No attributes provided" if @attributes.blank?
      end

      def run
        attributes_str = parse_attributes.join(" ")
        cmd = "rails generate model #{model_name.camelize} #{attributes_str} --force"
        ::Localtower::Tools.perform_cmd(cmd)

        insert_non_nullable_values
        insert_default_values
        insert_array
        insert_indexes
        insert_foreign_keys
      end

      private

      attr_reader :model_name, :attributes

      def parse_attributes
        attributes.map do |attr_hash|
          [
            attr_hash['column_name'],
            # we need this transformation of "array":
            (attr_hash['column_type'] == 'array' ? 'string' : attr_hash['column_type']),
            attr_hash["index"].present? ? 'index' : nil
          ].compact.join(':')
        end
      end

      def insert_array
        params = attributes
                 .select { |attr| attr['column_type'] == 'array' }
                 .map { |attr| attr['column_name'] }

        Localtower::Generators::ServiceObjects::InsertArray.new(params).call
      end

      def insert_default_values
        params = attributes
                 .select { |attr| attr['default'].present? }
                 .each_with_object([]) do |attr, arr|
          arr << Hash[attr['column_name'], attr['default']]
        end

        Localtower::Generators::ServiceObjects::InsertDefaults.new(params).call
      end

      def insert_non_nullable_values
        params = attributes
                 .select { |attr| attr['nullable'] == false }
                 .map { |attr| attr['column_name'] }

        ::Localtower::Generators::ServiceObjects::InsertNullable.new(params).call
      end

      def insert_indexes
        params = attributes
                 .select { |attr| attr["index"].present? }
                 .each_with_object([]) do |attr, arr|
          arr << Hash[attr['column_name'],
                      { "using" => attr['index'], "algorithm" => attr['index_algorithm'], "unique" => attr['unique'] }]
        end

        ::Localtower::Generators::ServiceObjects::InsertIndexes.new(params).call
      end

      def insert_foreign_keys
        params = attributes
                 .each_with_object([]) do |attr, arr|
          arr << Hash[attr['column_name'],
                      { "foreign_key" => attr['foreign_key'] }]
        end

        ::Localtower::Generators::ServiceObjects::InsertForeignKeys.new(params).call
      end
    end
  end
end
