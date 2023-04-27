Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :groups do
    #resources :hosts, :controller => :group_hosts
    
    collection do          
      get :check_groups
      #get :hosts
      get :hosts, to: 'group_hosts#index', as: 'group_hosts'
    end
  end

  resources :group_hosts, :as => :hosts
  
  get "/jquery-1" => "pages#jquery_1"
  get "/jquery-2" => "pages#jquery_2"
  get "/jquery-3" => "pages#jquery_3"
  get "/jquery-4" => "pages#jquery_4"
  get "/jquery-5" => "pages#jquery_5"
  get "/card-tab" => "pages#card_tab"

  root "pages#jquery_1"


end
