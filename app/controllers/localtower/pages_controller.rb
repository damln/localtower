require_dependency 'localtower/application_controller'

module Localtower
  class PagesController < ApplicationController

    def dashboard
    end

    def logs
      @logs = Localtower::Plugins::Capture.new.logs
    end

    def log
      file_content = Localtower::Plugins::Capture.log_from_md5(clean_params['md5'])

      render json: file_content
    end

    def log_var
      file_content = Localtower::Plugins::Capture.log_from_md5(clean_params['md5'])
      returned = file_content["variables"].select {|i| i["event_name"] == clean_params[:var] }[0]["returned"]

      render json: returned
    end

    def migrations
      @migrations = ::Localtower::Status.new.run
    end

    def post_migrations
      # Because we have a list or a field, take the item from the list in priority
      clean_params["migrations"]["migrations"] = clean_params["migrations"]["migrations"].map do |action_line|
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

      use_generator(::Localtower::Generators::Migration, clean_params["migrations"])
      redirect_to migrations_path
    end

    def relations
      @need_models = ::Localtower::Tools.enought_models_for_relation?
    end

    def post_relations
      use_generator(::Localtower::Generators::Relation, clean_params["relations"])
      redirect_to relations_path
    end

    # def tasks
    #   @tasks = ['rake db:migrate RAILS_ENV=test']
    # end

    # def post_tasks
    #   ::Localtower::Tools.perform_cmd(clean_params["task"]["name"], false)

    #   redirect_to tasks_path
    # end

    def models
    end

    def post_models
      use_generator(::Localtower::Generators::Model, clean_params["models"])
      redirect_to relations_path
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
