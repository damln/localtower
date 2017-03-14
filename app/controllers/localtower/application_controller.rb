module Localtower
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session
    before_action :check_environment

    def check_environment
      raise if Rails.env.production?
    end
  end
end
