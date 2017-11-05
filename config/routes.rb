Rails.application.routes.draw do
  root 'users#new'
  resources :users 
  resources :domains do
    resources :a_records
  end
  #sessions
  get '/login' => 'sessions#new'
  post '/sessions' => 'sessions#create'
  get '/logout' => 'sessions#destroy'

end
