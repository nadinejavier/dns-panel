Rails.application.routes.draw do
  root 'sessions#new'
  resources :domains do
    resources :a_records
  end
  #sessions
  get '/login' => 'sessions#new'
  post '/sessions' => 'sessions#create'
  get '/logout' => 'sessions#destroy'

  #Sign up
  get '/signup' => "users#new"
  post '/users' => 'users#create'
  get '/users/:id' => 'users#show', as: 'user'
 end
