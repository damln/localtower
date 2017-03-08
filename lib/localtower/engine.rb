module Localtower
  class Engine < ::Rails::Engine
    isolate_namespace Localtower

    initializer 'static assets' do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
  end
end
