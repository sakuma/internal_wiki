InternalWiki::Application.routes.draw do

  root :to => "wiki_informations#index"

  get "search" => "search#index", :as => 'search'

  get "login" => "sessions#new", :as => "login"
  post "login" => "sessions#create"
  delete "logout" => "sessions#destroy", :as => "logout"
  get "logout" => "sessions#destroy" # ログインできなくなる対策で
  get "oauth/callback" => "sessions#callback"
  get "oauth/:provider" => "sessions#oauth", :as => :auth_at_provider

  get "/setting" => "users#setting", :as => 'user_setting'
  put "/setting/:id" => "users#update", :as => 'update_setting'
  get "/users/:token/activate" => "users#activate", :as => 'activate_user'
  put "/users/:token/register" => "users#register", :as => 'regist_user'

  namespace :admin do
    resources :users do
      member do
        get :candidates_wiki
        post :add_visibility_wiki
        delete :delete_visibility_wiki
        get :resend_invite_mail
      end
    end
  end
  post "/admin/users/invite" => 'admin/users#invite_user', :as => 'invite_user'

  resources :wiki_infos, :controller => 'wiki_informations', :only => [:index, :new, :create]
  get ':wiki_name/candidates_users' => 'wiki_informations#visible_wiki_candidates_users', :as => :candidates_users
  get ':wiki_name' => 'wiki_informations#show', :as => 'wiki'
  get ':wiki_name/edit' => 'wiki_informations#edit', :as => 'edit_wiki_info'
  put ':wiki_name' => 'wiki_informations#update', :as => 'update_wiki'
  post ':wiki_name/add_authority_user' => 'wiki_informations#add_authority_user', :as => 'add_authority_user'
  delete '/:wiki_name/remove_authority_user' => 'wiki_informations#remove_authority_user', :as => 'remove_authority_user'
  delete '/:wiki_name' => 'wiki_informations#destroy', :as => 'wiki_info'

  scope ':wiki_name' do
    post '' => 'pages#create', :as => 'pages'
    get '/new' => 'pages#new', :as => 'new_page'
    get '/:page_name/histories' => 'pages#histories', :as => 'histories_page'
    put '/:page_name/histories/revert_page' => 'pages#revert', :as => 'revert_page'
    get '/:page_name' => 'pages#show', :as => 'page'
    get '/:page_name/edit' => 'pages#edit', :as => 'edit_page'
    put '/:page_name' => 'pages#update', :as => 'update_page'
    post '/:page_name/preview' => 'pages#preview', :as => 'preview_page'
    delete '/:page_name' => 'pages#destroy', :as => 'delete_page'
  end


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
