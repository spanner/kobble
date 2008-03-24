ActionController::Routing::Routes.draw do |map|
                                
  map.home '', :controller => 'login', :action => 'index'
  map.login '/login', :controller => 'login', :action => 'login'
  map.logout '/logout', :controller => 'login', :action => 'logout'
  map.repassword '/repassword', :controller => 'login', :action => 'repassword'
  
  map.catch '/:controller/catch/:id/:caughtClass/:caughtID', :action => 'catch'
  map.drop '/:controller/drop/:id/:droppedClass/:droppedID', :action => 'drop'
  map.trash '/:controller/trash/:id', :action => 'trash'
  map.home '/accounts/home', :action => 'home', :controller => 'accounts'

  [:sources, :bundles, :nodes, :people].each do |k|
    map.resources k, :has_many => :topics, :collection => { :gallery => :get } 
  end
  
  map.resources :tags, :has_many => :taggings, :collection => { :gallery => :get, :cloud => :get, :tree => :get, :treemap => :get } 
  map.resources :flags, :has_many => :flaggings
  map.resources :users, :has_many => :activations, :collection => { :gallery => :get }, :method => { :home => :get }
  map.resources :topics, :has_many => :posts
  map.resources :scratchpads, :has_many => :scraps

  map.resources :posts
  
  map.resources :activations, :collection => { :activate => :any }, :member => { :deactivate => :any, :toggle => :any }
  map.resources :monitorships, :member => { :toggle => :any }
  map.resources :accounts
  
  map.resource :search
  
#  map.connect ':controller/:action/:id'

#  map.search '/search/list/:q', :controller => 'search', :action => 'list'
#  map.searchgallery '/search/gallery/:q', :controller => 'search', :action => 'gallery'
  
end
