class PagesController < ApplicationController
  def home
    a = 2
    b = {hello: "World"}

    Localtower::Plugins::Capture.new(self, binding).save
  end
end
