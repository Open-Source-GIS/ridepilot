Ridepilot::Application.routes.draw do
  root :to => "home#index"

  devise_for :users, :controllers=>{:sessions=>"users"} do
    get "new_user" => "users#new_user"
    post "create_user" => "users#create_user"
    put "create_user" => "users#create_user"
    get "init" => "users#show_init"
    post "init" => "users#init"
    post "change_provider" => "users#change_provider"
  end

  resources :customers do
    post :inactivate, :as=>:inactivate
    get "search", :on=>:collection
    get :all, :on=>:collection
    get :found, :on=>:collection
    get :autocomplete, :on=>:collection
  end

  resources :trips do 
    post :reached, :as => :reached
    post :unreached, :as => :unreached
    post :confirm, :as => :confirm
    post :turndown, :as => :turndown
    post :no_show, :as => :no_show
    post :send_to_cab, :as => :send_to_cab
    get :trips_requiring_callback, :on=>:collection
    get :reconcile_cab, :on=>:collection
    get :unscheduled, :on=>:collection
  end

  resources :repeating_trips

  resources :providers do
    post :delete_role
    post :change_role
  end

  resources :addresses do
    get :find_or_create, :on=>:collection
    get :autocomplete, :on=>:collection
  end

  resources :drivers
  resources :vehicles
  resources :vehicle_maintenance_events
  resources :monthlies
  resources :funding_sources
  resources :runs do
    get :uncompleted_runs, :on=>:collection
  end

  match 'reports', :controller=>:reports, :action=>:index
  match 'reports/:action/:id', :controller=>:reports
  match 'reports/:action', :controller=>:reports

  root :to => "home#index"

end
