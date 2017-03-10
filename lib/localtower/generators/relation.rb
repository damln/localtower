module Localtower
  module Generators
    class Relation
      def initialize(opts)
        @opts = JSON[opts.to_json]
      end

      def run
        model_one_name = @opts["model_one_name"]
        model_two_name = @opts["model_two_name"]

        if not model_one_name.present? and not model_two_name.present?
          return nil
        end

        if @opts["model_name"].present?
          model_name = @opts["model_name"].capitalize
        else
          model_name = "#{model_one_name.capitalize}#{model_two_name.capitalize}"
        end

        data = {
          run_migrate: true,
          model_name: model_name,
          attributes: [
            {
              attribute_name: model_one_name.downcase,
              attribute_type: "references"
            },
            {
              attribute_name: model_two_name.downcase,
              attribute_type: "references"
            },
          ]
        }

        ::Localtower::Generators::Model.new(data.deep_stringify_keys).run

        # model 1:
        file = "#{Rails.root}/app/models/#{model_one_name.underscore}.rb"
        after = /class #{model_one_name} < ApplicationRecord\n/
        line1 = "  has_many :#{model_name.pluralize.underscore}\n"
        line2 = "  has_many :#{model_two_name.pluralize.underscore}, through: :#{model_name.pluralize.underscore}\n"

        ::Localtower::Tools::ThorTools.new.insert_after_word(file, after, line1)
        ::Localtower::Tools::ThorTools.new.insert_after_word(file, after, line2)

        # model 2:
        file = "#{Rails.root}/app/models/#{model_two_name.underscore}.rb"
        after = /class #{model_two_name} < ApplicationRecord\n/
        line1 = "  has_many :#{model_name.pluralize.underscore}\n"
        line2 = "  has_many :#{model_one_name.pluralize.underscore}, through: :#{model_name.pluralize.underscore}\n"

        ::Localtower::Tools::ThorTools.new.insert_after_word(file, after, line1)
        ::Localtower::Tools::ThorTools.new.insert_after_word(file, after, line2)
      end
    end
  end
end
