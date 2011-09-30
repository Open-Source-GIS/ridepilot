Ridepilot::Application.routes.draw do
  root :to => "home#index"

  devise_for :users, :controllers=>{:sessions=>"users"} do
    get "new_user" => "users#new_user"
    post "create_user" => "users#create_user"
    put "create_user" => "users#create_user"
    get "init" => "users#show_init"
    post "init" => "users#init"
    post "change_provider" => "users#change_provider"
    get "show_change_password" => "users#show_change_password"
    match "change_password"  => "users#change_password"
  end

  resources :customers do
    post :inactivate, :as => :inactivate
    
    collection do
      get :search
      get :all
      get :found
      get :autocomplete
    end
  end

  resources :trips do 
    post :reached, :as => :reached
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
    member do
      post :change_dispatch
      post :change_scheduling
    end
  end

  resources :addresses do
    collection do
      get :autocomplete
      get :search
    end
  end
  
  resources :device_pools, :except => [:index, :destroy] do
    resources :device_pool_drivers, :only => [:create, :destroy]
  end
  
  resources :drivers
  resources :vehicles
  resources :vehicle_maintenance_events
  resources :monthlies
  resources :funding_sources
  resources :runs do
    collection do
      get :uncompleted_runs
      get :for_date
    end
  end
  
  scope :via => :post, :constraints => { :format => "json" , :protocol => "https" } do
    match 'device_pool_drivers/' => "v1/device_pool_drivers#index", :as => "v1_device_pool_drivers"
    match 'v1/device_pool_drivers/:id' => "v1/device_pool_drivers#update", :as => "v1_device_pool_driver"
  end
  
  match 'reports', :controller=>:reports, :action=>:index
  match 'reports/:action/:id', :controller=>:reports
  match 'reports/:action', :controller=>:reports
  match 'dispatch', :controller => :dispatch, :action => :index
  
  match "test_exception_notification" => "application#test_exception_notification"

  root :to => "home#index"

end
