Localtower::Engine.routes.draw do
  get 'migrations/new', to: 'pages#new_migration', as: :new_migration
  get 'migrations', to: 'pages#migrations', as: :migrations
  post 'migrations', to: 'pages#post_migrations'

  get 'models/new', to: 'pages#new_model', as: :new_model
  get 'models', to: 'pages#models', as: :models
  post 'models', to: 'pages#post_models'

  post 'actions', to: 'pages#post_actions', as: :actions

  root :to => redirect('models/new')
end
