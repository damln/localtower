Rails.application.routes.draw do
  if defined?(Localtower)
    mount ::Localtower::Engine, at: "localtower"
  end

  root to: "pages#home"
end
