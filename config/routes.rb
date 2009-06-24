ActionController::Routing::Routes.draw do |map|
                                  
  
  # map.login '/login', :controller => 'login', :action => 'login'
  # map.logout '/logout', :controller => 'login', :action => 'logout'
  # map.repassword '/repassword', :controller => 'login', :action => 'repassword'
  # map.forbidden '/forbidden', :controller => 'login', :action => 'forbidden'

  # map.collection_upload '/collection/:collection_id/upload', :controller => 'sources', :action => 'upload'
  map.uploader '/uploader', :controller => 'sources', :action => 'upload'
  map.describer '/describer', :controller => 'sources', :action => 'describe'

  
  # catch and drop are dispatched by controllers and can't be restful
  
  # map.catch '/:controller/catch/:id/:caughtClass/:caughtID', :action => 'catch'
  # map.drop '/:controller/drop/:id/:droppedClass/:droppedID', :action => 'drop'
  
  map.resources :accounts, 
                :has_many => [:users, :collections, :events, :deletions], 
                :member => { :permissions => :any }

  map.resources :users, 
                :has_many => [:events, :user_preferences, :bookmarkings], 
                :member => {:home => :get, :recover => :post, :eliminate => :post, :reinvite => :any, :predelete => :get} do |user|
                  
    # user.resources :bookmarkings, :collection => {:remove => :post}
    
  end

  map.resources :collections, 
                :has_many => [:events, :permissions, :topics, :annotations], 
                :member => {:recover => :post, :eliminate => :post, :predelete => :get} do |collection|

    collection.resources :annotations, :name_prefix => nil
    collection.resources :users, :has_many => :bookmarkings      # nasty longcut to supply both user and collection to bench drop action

    collection.resources :sources, :name_prefix => nil,
                  :has_many => [:topics, :nodes, :annotations, :taggings],
                  :collection => {:upload => :any},
                  :member => {:annotate => :post, :recover => :post, :eliminate => :post, :describe => :put}

    collection.resources :nodes, :name_prefix => nil,
                  :has_many => [:topics, :annotations, :taggings],
                  :member => {:annotate => :post, :recover => :post, :eliminate => :post, :catch => :get}

    collection.resources :bundles, :name_prefix => nil,
                  :has_many => [:topics, :bundlings, :annotations, :taggings],
                  :member => {:annotate => :post, :recover => :post, :eliminate => :post, :catch => :get, :drop => :get}

    collection.resources :people, :name_prefix => nil,
                  :has_many => [:topics, :annotations, :taggings],
                  :member => {:annotate => :post, :recover => :post, :eliminate => :post, :catch => :get}

    collection.resources :occasions, :name_prefix => nil,
                  :has_many => [:topics, :annotations, :taggings],
                  :member => {:annotate => :post, :recover => :post, :eliminate => :post, :catch => :get}

    collection.resources :tags, :name_prefix => nil,
                  :has_many => [:taggings, :topics, :annotations],
                  :collection => {:cloud => :get, :tree => :get, :treemap => :get, :matching => :any, :drop => :get}, 
                  :member => {:recover => :post, :eliminate => :post, :catch => :get}

    collection.resources :topics, :name_prefix => nil,
                  :has_many => [:posts], 
                  :collection => {:latest => :get},
                  :member => {:recover => :post, :eliminate => :post}

    collection.resources :posts, :name_prefix => nil,
                  :member => {:recover => :post, :eliminate => :post}

  end

  map.resources :preferences
  map.resources :events
  map.resources :user_preferences, :member => {:activate => :any, :deactivate => :any, :toggle => :any}
  map.resources :activations, :member => {:activate => :any, :deactivate => :any, :toggle => :any}
  map.resources :permissions, :member => {:activate => :any, :deactivate => :any, :toggle => :any}
  map.resources :monitorships, :member => {:activate => :any, :deactivate => :any, :toggle => :any}
  map.resources :annotation_types, :has_many => :annotations
  
  map.resource :search, :member => { :list => :any, :gallery => :any }
  map.resource :user_session

  map.root :controller => "accounts", :action => "index"
  
end
