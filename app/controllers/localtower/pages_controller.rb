require_dependency 'localtower/application_controller'

module Localtower
  class PagesController < ApplicationController
    def new_migration
      @models = ::Localtower::Tools.models_presented
    end

    def migrations
      @migrations = ::Localtower::Status.new.run
    end

    def post_migrations
      # Because we have a list or a field, take the item from the list in priority
      migrations = clean_params["migrations"].map do |action_line|
        # This is used for "rename_column" action:
        action_line["new_column_type"] = action_line["column_type"]

        if action_line["column_list"].present?
          action_line["column"] = action_line["column_list"]
        end

        action_line.delete("column_list")
        # / This is used for "rename_column" action

        action_line
      end

      use_generator(::Localtower::Generators::Migration, migrations)

      redirect_to migrations_path
    end

    def new_model
    end

    def models
      @models = ::Localtower::Tools.models_presented
    end

    def post_models
      model = clean_params["model"]
      model['attributes'] = model['attributes'].map do |attribute_line|
        # Convert checkbox to ruby value:
        attribute_line['nullable'] = false if attribute_line['nullable'].blank?

        # Convert index hash:
        if attribute_line['index']
          attribute_line['index']['unique'] = true if attribute_line['index']['unique'] == 'true'
        end

        attribute_line
      end

      use_generator(::Localtower::Generators::Model, model)
      redirect_to migrations_path
    end

    def post_actions
      cmd = ::Localtower::Tools.perform_cmd(clean_params['cmd'])
      flash[:notice] = cmd if cmd['ERROR']
      redirect_back fallback_location: root_path
    end

    private

    def use_generator(generator_klass, options)
      generator_klass.new(options).run
    end

    def clean_params
      params.permit!.to_hash.with_indifferent_access
    end
  end
end
