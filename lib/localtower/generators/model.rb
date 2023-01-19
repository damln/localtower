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
        cmd = "rails generate model #{model_name.camelize} #{attributes_str}"

        ::Localtower::Tools.perform_cmd(cmd)

        insert_non_nullable_values
        insert_default_values
        insert_array
        insert_indexes
      end

      private

      attr_reader :model_name
      attr_reader :attributes

      def parse_attributes
        attributes.map do |attr_hash|
          [
            attr_hash['attribute_name'],
            (attr_hash['attribute_type'] == 'array' ? 'string' : attr_hash['attribute_type']), # we need this transformation of "array"
            (attr_hash.dig('index', 'using') != 'none') ? 'index' : nil
          ].compact.join(':')
        end
      end

      def insert_array
        params = attributes
          .select { |attr| attr['attribute_type'] == 'array' }
          .map { |attr| attr['attribute_name'] }

        Localtower::Generators::ServiceObjects::InsertArray.new(params).call
      end

      def insert_default_values
        params = attributes
          .reject { |attr| attr['default'] == nil }
          .reject { |attr| attr['default'] == '' }
          .each_with_object([]) do |attr, arr|
          arr << Hash[attr['attribute_name'], attr['default']]
        end

        Localtower::Generators::ServiceObjects::InsertDefaults.new(params).call
      end

      def insert_non_nullable_values
        params = attributes
          .select { |attr| attr['nullable'] == false }
          .map{ |attr| attr['attribute_name'] }

        ::Localtower::Generators::ServiceObjects::InsertNullable.new(params).call
      end

      def insert_indexes
        params = attributes
          .select { |attr| attr.dig('index', 'using').present? }
          .reject { |attr| attr.dig('index', 'using') == 'none' }
          .each_with_object([]) do |attr, arr|
            arr << Hash[attr['attribute_name'], attr['index']]
          end

        ::Localtower::Generators::ServiceObjects::InsertIndexes.new(params).call
      end
    end
  end
end
