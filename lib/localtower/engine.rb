module Localtower
  class Engine < ::Rails::Engine
    isolate_namespace Localtower

    initializer 'localtower.add_static_assets', before: :build_middleware_stack do |app|
      app.config.middleware.use Rack::Deflater
      app.config.middleware.use ::ActionDispatch::Static, "#{root}/public"
      # Later: have a better assets pipeline to be able to version and cache assets forever
      # app.config.middleware.use ::ActionDispatch::Static, "#{root}/public", headers: { "Cache-Control" => "public, max-age=31536000" }
    end
  end
end
