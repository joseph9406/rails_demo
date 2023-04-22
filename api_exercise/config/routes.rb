Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"  
  
  namespace :api, :defaults => { :format => :json } do
    namespace :v1 do

      #resources :trains, :only => [:index, :show]
      get "/trains" => "trains#index", :as => :trains
      get "/trains/:train_number" => "trains#show", :as => :train

      #resources :reservations, :ony => [:show, :create, :update, :destroy]
      get "/reservations/:booking_code" => "reservations#show", :as => :reservation
      post "/reservations" => "reservations#create", :as => :create_reservations
      patch "/reservations/:booking_code" => "reservations#update", :as => :update_reservation
      delete "/reservations/:booking_code" => "reservations#destroy", :as => :cancel_reservation

      get "/reservations" => "reservations#index", :as => :reservations

      # ***** 2.3, 5. 實作註冊、登入、登出 API *****
      post "/signup" => "auth#signup"   # 註冊
      post "/login" => "auth#login"     
      post "/logout" => "auth#logout"   

      # ***** 2.3, 6. 實作用戶更新資料 API *****
      get "/me" => "users#show", :as => :user
      patch "/me" => "users#update", :as => :update_user
      
    end
  end

  root "welcome#index"
end
