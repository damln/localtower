require_dependency 'localtower/application_controller'

module Localtower
  class PagesController < ApplicationController

    def dashboard
    end

    def logs
      @logs = Localtower::Plugins::Capture.new.logs
    end

    def log
      file = Dir["#{Localtower::Plugins::Capture::LOG_PATH.call}/localtower*#{params[:md5]}*"][0]

      render json: JSON.parse(open(file).read)
    end

    def log_var
      answer = {}

      file = Dir["#{Localtower::Plugins::Capture::LOG_PATH.call}/localtower*#{params[:md5]}*"][0]
      data = JSON.parse(open(file).read)

      answer = data["variables"].select {|i| i["event_name"] == params[:var] }[0]["returned"]

      render json: answer
    end

    def status
      @data = ::Localtower::Status.new.run
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
      redirect_to migrations_path
    end

    def relations
    end

    def post_relations
      use_generator(::Localtower::Generators::Relation, params[:relations])
      redirect_to relations_path
    end

    def models
    end

    def post_models
      use_generator(::Localtower::Generators::Model, params[:models])
      redirect_to relations_path
    end

    private

    def use_generator(generator_klass, options)
      generator_klass.new(options).run
    end

  end
end
