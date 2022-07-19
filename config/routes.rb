Localtower::Engine.routes.draw do
  get "migrations", to: "pages#migrations", as: :migrations
  post "migrations", to: "pages#post_migrations"

  get "models", to: "pages#models", as: :models
  post "models", to: "pages#post_models"

  get "relations", to: "pages#relations", as: :relations
  post "relations", to: "pages#post_relations"

  # get "tasks", to: "pages#tasks", as: :tasks
  # post "tasks", to: "pages#post_tasks"

  # get ':v/:asset', to: 'pages#asset_render', as: 'asset_render', :constraints => { :v => /[^\/]*/, :asset => /[^\/]*/ }

  get 'dashboard', to: 'pages#dashboard', as: 'dashboard'
  get 'logs', to: 'pages#logs', as: 'logs'
  get 'logs/:md5', to: 'pages#log', as: 'log'
  get 'logs/:md5/:var', to: 'pages#log_var', as: 'log_var'

  root :to => redirect('dashboard')
end
