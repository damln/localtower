require_dependency 'localtower/application_controller'

module Localtower
  class PagesController < ApplicationController
    def new_migration
      @migrations = ::Localtower::Status.new.run.select { |i| i["status"] == :todo }
      @models = ::Localtower::Tools.models_presented
    end

    def migrations
      @migrations = ::Localtower::Status.new.run.take(30)
    end

    def post_migrations
      migrations = JSON.parse(clean_params['migrations'])

      ::Localtower::Generators::Migration.new(migrations, clean_params['migration_name']).run

      redirect_to new_migration_path
    end

    def new_model; end

    def post_models
      model = clean_params["model"]
      model['attributes'] = JSON.parse(model['attributes']).map do |attribute_line|
        # Convert checkbox to ruby value:
        attribute_line['nullable'] = false if attribute_line['nullable'].blank?
        attribute_line['index'] = nil if attribute_line['index'].blank?

        attribute_line
      end

      if model['attributes'].all? { |i| i['column_name'].present? }
        ::Localtower::Generators::Model.new(model).run
        redirect_to migrations_path
      else
        redirect_back fallback_location: root_path
      end
    end

    def rm_file
      File.delete(clean_params['file']) if File.exist?(clean_params['file'])
      redirect_back fallback_location: migrations_path
    end

    def post_actions
      cmd = ::Localtower::Tools.perform_cmd(clean_params['cmd'])
      flash[:notice] = cmd if cmd['ERROR']

      redirect_back fallback_location: root_path
    end

    private

    def clean_params
      params.permit!.to_hash.with_indifferent_access
    end
  end
end
