Ridepilot::Application.routes.draw do
  root :to => "home#index"

  devise_for :users, :controllers=>{:sessions=>"users"} do
    get "init" => "users#show_init"
    post "init" => "users#init"
  end

  resources :customers do
    get "search", :on=>:collection
    get :autocomplete_customer_first_name, :on=>:collection
  end

  resources :trips do 
    post :reached, :as => :reached
    post :unreached, :as => :unreached
    post :confirm, :as => :confirm
    post :turndown, :as => :turndown
    get :trips_requiring_callback, :on=>:collection
    get :unscheduled, :on=>:collection
  end

  resources :repeating_trips

  root :to => "home#index"

end
