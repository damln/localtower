Rails.application.routes.draw do
  if defined?(Localtower)
    mount ::Localtower::Engine, at: "localtower"
  end
end
