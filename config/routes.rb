Localtower::Engine.routes.draw do
  get "migrations", to: "pages#migrations", as: :migrations
  post "migrations", to: "pages#post_migrations"

  get "models", to: "pages#models", as: :models
  post "models", to: "pages#post_models"

  get "relations", to: "pages#relations", as: :relations
  post "relations", to: "pages#post_relations"

  get "status", to: "pages#status", as: :status
  # get ':v/:asset', to: 'pages#asset_render', as: 'asset_render', :constraints => { :v => /[^\/]*/, :asset => /[^\/]*/ }

  get 'dashboard', to: 'pages#dashboard', as: 'dashboard'

  root :to => redirect('dashboard')
end
