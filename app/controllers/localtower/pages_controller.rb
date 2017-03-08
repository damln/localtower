require_dependency 'localtower/application_controller'

module Localtower
  class PagesController < ApplicationController

    def dashboard
    end

    def migrations
    end

    def post_migrations
      # Because we have a list or a field, take the item from the list in priority
      params[:migrations][:migrations] = params[:migrations][:migrations].map do |action_line|
        action_line["new_column_type"] = action_line["column_type"]

        if action_line["column"].present?
          action_line["column"] = action_line["column"]
        end

        if action_line["column_list"].present?
          action_line["column"] = action_line["column_list"]
        end

        action_line.delete("column_list")

        action_line
      end

      use_generator(::Localtower::Generators::Migration, params[:migrations])
    end

    def relations
    end

    def post_relations
      use_generator(::Localtower::Generators::Relation, params[:relations])
    end

    def models
    end

    def post_models
      use_generator(::Localtower::Generators::Model, params[:models])
    end

    private

    def use_generator(generator_klass, options)
      generator = generator_klass.new(options)
      generator.run
      redirect_to :back
    end
  end
end
