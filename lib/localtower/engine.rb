module Localtower
  class Engine < ::Rails::Engine
    isolate_namespace Localtower

    initializer 'localtower.add_static_assets', before: :build_middleware_stack do |app|
      app.config.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
  end
end
