ActionController::Routing::Routes.draw do |map|
                                
  map.home '', :controller => 'login', :action => 'index'
  map.login '/login', :controller => 'login', :action => 'login'
  map.logout '/logout', :controller => 'login', :action => 'logout'
  map.repassword '/repassword', :controller => 'login', :action => 'repassword'
  
  map.catch '/:controller/catch/:id/:caughtClass/:caughtID', :action => 'catch'
  map.drop '/:controller/drop/:id/:droppedClass/:droppedID', :action => 'drop'
  map.trash '/:controller/trash/:id', :action => 'trash'
  
  map.resources :accounts, :collection => { :home => :any }
  map.resources :collections

  map.resources :sources, :has_many => [:topics, :nodes], :collection => { :gallery => :get }, :member => {:annotate => :post}
  map.resources :nodes, :has_many => :topics, :collection => { :gallery => :get }, :member => {:annotate => :post}
  map.resources :bundles, :has_many => [:topics, :members], :collection => { :gallery => :get }, :member => {:annotate => :post}
  map.resources :people, :collection => { :gallery => :get }, :member => {:annotate => :post}
  map.resources :occasions, :collection => { :gallery => :get }, :member => {:annotate => :post}
  
  map.resources :tags, :has_many => [:taggings, :topics], :collection => { :gallery => :get, :cloud => :get, :tree => :get, :treemap => :get, :matching => :any } 
  map.resources :flags, :has_many => :flaggings
  map.resources :topics, :has_many => :posts, :collection => { :latest => :get }
  map.resources :scratchpads, :has_many => :scraps
  map.resources :posts

  map.resources :users, :has_many => [:activations, :user_preferences], :collection => { :gallery => :get }, :member => { :home => :get }
  map.resources :preferences
  map.resources :user_preferences, :member => { :activate => :any, :deactivate => :any, :toggle => :any }
  map.resources :activations, :member => { :activate => :any, :deactivate => :any, :toggle => :any }
  map.resources :monitorships, :member => { :activate => :any, :deactivate => :any, :toggle => :any }
  
  map.resource :search, :member => { :list => :any, :gallery => :any }
  
end
