ActionController::Routing::Routes.draw do |map|
                                  
  
  # map.login '/login', :controller => 'login', :action => 'login'
  # map.logout '/logout', :controller => 'login', :action => 'logout'
  # map.repassword '/repassword', :controller => 'login', :action => 'repassword'
  # map.forbidden '/forbidden', :controller => 'login', :action => 'forbidden'

  map.collection_upload '/collection/:collection_id/upload', :controller => 'sources', :action => 'upload'
  map.uploader '/uploader', :controller => 'sources', :action => 'upload'
  map.describer '/describer', :controller => 'sources', :action => 'describe'

  
  # catch and drop are dispatched by controllers and can't be restful
  
  map.catch '/:controller/catch/:id/:caughtClass/:caughtID', :action => 'catch'
  map.drop '/:controller/drop/:id/:droppedClass/:droppedID', :action => 'drop'
  
  map.resources :accounts, :has_many => [:users, :collections, :events, :deletions, :tags], :member => { :permissions => :any }
  map.resources :collections, :has_many => [:events, :topics, :annotations, :permissions, :sources, :nodes, :bundles, :people, :tags, :topics, :occasions], :member => {:recover => :post, :eliminate => :post, :predelete => :get}, :collection => { :gallery => :get }
  map.resources :users, :has_many => [:activations, :user_preferences, :permissions, :scratchpads, :events, :sources, :nodes, :bundles, :people, :topics, :posts], :collection => { :gallery => :get }, :member => { :home => :get, :recover => :post, :eliminate => :post, :reinvite => :any, :predelete => :get }

  map.resources :annotations
  map.resources :preferences
  map.resources :events

  map.resources :sources, :has_many => [:topics, :nodes, :annotations], :collection => { :gallery => :get }, :member => {:annotate => :post, :recover => :post, :eliminate => :post, :describe => :put}
  map.resources :nodes, :has_many => [:topics, :annotations], :collection => { :gallery => :get }, :member => {:annotate => :post, :recover => :post, :eliminate => :post}
  map.resources :bundles, :has_many => [:topics, :members, :annotations], :collection => { :gallery => :get }, :member => {:annotate => :post, :recover => :post, :eliminate => :post}
  map.resources :people, :has_many => [:topics, :annotations], :collection => { :gallery => :get }, :member => {:annotate => :post, :recover => :post, :eliminate => :post}
  map.resources :occasions, :has_many => [:topics, :annotations], :collection => { :gallery => :get }, :member => {:annotate => :post, :recover => :post, :eliminate => :post}
  
  map.resources :tags, :has_many => [:taggings, :topics, :annotations], :collection => { :gallery => :get, :cloud => :get, :tree => :get, :treemap => :get, :matching => :any }, :member => {:recover => :post, :eliminate => :post}
  map.resources :topics, :has_many => :posts, :collection => { :latest => :get }, :member => {:recover => :post, :eliminate => :post}
  map.resources :scratchpads, :has_many => :scraps
  map.resources :posts, :member => {:recover => :post, :eliminate => :post}

  map.resources :user_preferences, :member => { :activate => :any, :deactivate => :any, :toggle => :any }
  map.resources :activations, :member => { :activate => :any, :deactivate => :any, :toggle => :any }
  map.resources :permissions, :member => { :activate => :any, :deactivate => :any, :toggle => :any }
  map.resources :monitorships, :member => { :activate => :any, :deactivate => :any, :toggle => :any }
  map.resources :annotation_types, :has_many => [:annotations]
  
  map.resource :search, :member => { :list => :any, :gallery => :any }
  map.resource :user_session

  map.root :controller => "accounts", :action => "index"
  
  
end
