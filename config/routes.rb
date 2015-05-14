Rails.application.routes.draw do

  root to: "static_pages#index"

  get '/update' => 'static_pages#update'
  get '/index' => "static_pages#index"

end
