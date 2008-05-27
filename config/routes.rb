ActionController::Routing::Routes.draw do |map|
                                
  map.home '', :controller => 'login', :action => 'index'
  map.login '/login', :controller => 'login', :action => 'login'
  map.logout '/logout', :controller => 'login', :action => 'logout'
  map.repassword '/repassword', :controller => 'login', :action => 'repassword'
  
  map.catch '/:controller/catch/:id/:caughtClass/:caughtID', :action => 'catch'
  map.drop '/:controller/drop/:id/:droppedClass/:droppedID', :action => 'drop'
  map.trash '/:controller/trash/:id', :action => 'trash'
  
  map.resources :accounts, :has_many => [:users, :collections, :events, :deletions, :tags], :collection => { :home => :any }
  map.resources :collections, :has_many => [:events, :topics], :member => {:recover => :post}, :collection => { :gallery => :get }
  map.resources :users, :has_many => [:activations, :user_preferences, :permissions, :scratchpads, :events, :sources, :nodes, :bundles, :people], :collection => { :gallery => :get }, :member => { :home => :get, :recover => :post }
  map.resources :annotations
  map.resources :preferences

  map.resources :sources, :has_many => [:topics, :nodes, :annotations], :collection => { :gallery => :get }, :member => {:annotate => :post, :recover => :post}
  map.resources :nodes, :has_many => [:topics, :annotations], :collection => { :gallery => :get }, :member => {:annotate => :post, :recover => :post}
  map.resources :bundles, :has_many => [:topics, :members, :annotations], :collection => { :gallery => :get }, :member => {:annotate => :post, :recover => :post}
  map.resources :people, :has_many => [:topics, :annotations], :collection => { :gallery => :get }, :member => {:annotate => :post, :recover => :post}
  map.resources :occasions, :has_many => [:topics, :annotations], :collection => { :gallery => :get }, :member => {:annotate => :post, :recover => :post}
  
  map.resources :tags, :has_many => [:taggings, :topics, :annotations], :collection => { :gallery => :get, :cloud => :get, :tree => :get, :treemap => :get, :matching => :any }, :member => {:recover => :post}
  map.resources :flags, :has_many => :flaggings, :member => {:recover => :post}
  map.resources :topics, :has_many => :posts, :collection => { :latest => :get }, :member => {:recover => :post}
  map.resources :scratchpads, :has_many => :scraps
  map.resources :posts, :member => {:recover => :post}

  map.resources :user_preferences, :member => { :activate => :any, :deactivate => :any, :toggle => :any }
  map.resources :activations, :member => { :activate => :any, :deactivate => :any, :toggle => :any }
  map.resources :monitorships, :member => { :activate => :any, :deactivate => :any, :toggle => :any }
  map.resources :annotation_types, :has_many => [:annotations]
  
  map.resource :search, :member => { :list => :any, :gallery => :any }
  
end
