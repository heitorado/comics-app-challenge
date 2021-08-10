Rails.application.routes.draw do
  root 'comics#index'
  get '/search_by_character', to: 'comics#search_by_character'
  post '/comics/:comic_id/favourite', to: 'comics#favourite_comic', as: 'favourite_comic'
  post '/comics/:comic_id/unfavourite', to: 'comics#unfavourite_comic', as: 'unfavourite_comic'
end
