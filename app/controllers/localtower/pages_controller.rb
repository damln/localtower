require_dependency 'localtower/application_controller'

module Localtower
  class PagesController < ApplicationController
    before_action :set_migrations, only: [:migrations, :models]

    def schema
    end

    def migrations
    end

    def post_migrations
      # Because we have a list or a field, take the item from the list in priority
      migrations = clean_params["migrations"]["migrations"].map do |action_line|
        # This is used for "rename_column" action:
        action_line["new_column_type"] = action_line["column_type"]

        if action_line["column_list"].present?
          action_line["column"] = action_line["column_list"]
        end

        action_line.delete("column_list")
        # / This is used for "rename_column" action

        action_line
      end

      use_generator(::Localtower::Generators::Migration, { 'migrations' => migrations })
      redirect_to migrations_path
    end

    def models
    end

    def post_models
      use_generator(::Localtower::Generators::Model, clean_params["models"])
      redirect_to models_path
    end

    def post_actions
      ::Localtower::Tools.perform_cmd(clean_params['cmd'], false)
      redirect_back fallback_location: root_path
    end

    private

    def set_migrations
      @migrations = ::Localtower::Status.new.run.select { |entry| entry['status'] == :todo }
    end

    def use_generator(generator_klass, options)
      generator_klass.new(options).run
    end

    def clean_params
      params.permit!.to_hash.with_indifferent_access
    end
  end
end
