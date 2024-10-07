require_dependency 'localtower/application_controller'

module Localtower
  class PagesController < ApplicationController
    def new_migration
      @migrations = ::Localtower::Status.new.run.select { |i| i["status"] == :todo }
      @models = ::Localtower::Tools.models_presented
    end

    def migrations
      @migrations = ::Localtower::Status.new.run
    end

    def post_migrations
      migrations = JSON.parse(clean_params['migrations'])

      use_generator(::Localtower::Generators::Migration, migrations)

      redirect_to migrations_path
    end

    def new_model; end

    def models
      @models = ::Localtower::Tools.models_presented
    end

    def post_models
      model = clean_params["model"]
      model['attributes'] = JSON.parse(model['attributes']).map do |attribute_line|
        # Convert checkbox to ruby value:
        attribute_line['nullable'] = false if attribute_line['nullable'].blank?
        attribute_line['index'] = nil if attribute_line['index'].blank?

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
