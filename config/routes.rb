Localtower::Engine.routes.draw do
  get 'migrations', to: 'pages#migrations', as: :migrations
  post 'migrations', to: 'pages#post_migrations'

  get 'models', to: 'pages#models', as: :models
  post 'models', to: 'pages#post_models'

  # get ':v/:asset', to: 'pages#asset_render', as: 'asset_render', :constraints => { :v => /[^\/]*/, :asset => /[^\/]*/ }
  get 'schema', to: 'pages#schema', as: 'schema'
  post 'actions', to: 'pages#post_actions', as: 'actions'

  root :to => redirect('models')
end
