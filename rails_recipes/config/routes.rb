Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :events do
    # ***** 16-2 建立報名、16-3 多步驟表單(wizards) *****
    resources :registrations do
      member do
        get "steps/1" => "registrations#step1", :as => :step1
        patch "steps/1/update" => "registrations#step1_update", :as => :update_step1        
        get "steps/2" => "registrations#step2", :as => :step2
        patch "steps/2/update" => "registrations#step2_update", :as => :update_step2       
        get "steps/3" => "registrations#step3", :as => :step3
        patch "steps/3/update" => "registrations#step3_update", :as => :update_step3
      end
    end
  end
  
  resource :user  # 這個單數的用意是指唯一自己，登入作戶也不能修改其他人的資。

  namespace :admin do     #定義了一個命名空間,並在其中定義了其他資源。    
    resources :events do
      resources :registrations, :controller => "event_registrations"  
      resources :tickets, :controller => :event_tickets
      collection do
        post :bulk_update
      end 
      
      member do
        post :reorder
      end

    end

    resources :categories
    resources :users do
      resource :profile, :controller => :user_profiles
    end
    
    root "events#index"   #访问 "/admin" 路径时，会执行 "events#index" 动作。
  end

  
  get "/jquery-1" => "pages#jquery_1"
  get "/jquery-2" => "pages#jquery_2"
  get "/jquery-3" => "pages#jquery_3"
  get "/jquery-4" => "pages#jquery_4"
  get "/jquery-5" => "pages#jquery_5"
  get "/card-tab" => "pages#card_tab"
  
  root "events#index"

end
