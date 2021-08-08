Rails.application.routes.draw do
  root 'comics#index'
  get '/search_by_character', to: 'comics#search_by_character'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
