MTurkRails::Application.routes.draw do

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Mturk tasks
  get 'experiments/select_item', to: 'experiments/select_item#index'
  get 'experiments/select_item/results', to: 'experiments/select_item#results'

  # Main app
  root                            to: 'static_pages#home'
  get '/help',                    to: 'static_pages#help'

  # login / logout etc.
  get '/signin',                  to: 'sessions#new'
  put '/signin',                  to: 'sessions#new'
  get '/signup',                  to: 'identities#new'
  get '/auth/:provider/callback', to: 'sessions#create'
  post '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure',            to: 'sessions#failure'
  get '/signout',                 to: 'sessions#destroy', :as => :signout

  # mTurk
  get '/mturk/task',                to: 'mturk#task'
  get '/mturk/tasks',               to: 'mturk#tasks'
  get '/mturk/assignments',         to: 'mturk#assignments'
  get '/mturk/items',               to: 'mturk#items'
  get '/mturk/stats',               to: 'mturk#stats'
  get '/mturk/results/:itemId/preview', to: 'mturk#preview_item'
  post '/mturk/report_item',        to: 'mturk#report_item'
  post '/mturk/report',             to: 'mturk#report'
  post '/mturk/coupon',             to: 'mturk#coupon'
  post '/mturk/destroy_item',       to: 'mturk#destroy_item'
  post '/mturk/approve_assignment', to: 'mturk#approve_assignment'
  post '/mturk/reject_assignment',  to: 'mturk#reject_assignment'

  post '/mturk/update_items',        to: 'mturk#update_items'

  #resources :identities

  #get "/home", to: "static_pages/home"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   get 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   get 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
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
  # get ':controller(/:action(/:id))(.:format)'
end
