ActionController::Routing::Routes.draw do |map|
                                
  map.home '', :controller => 'login', :action => 'index'
  map.login '/login', :controller => 'login', :action => 'login'
  map.logout '/logout', :controller => 'login', :action => 'logout'
  map.search '/search/:q', :controller => 'search', :action => 'index'
  
  map.catch '/:controller/catch/:id/:caughtClass/:caughtID', :action => 'catch'
  map.drop '/:controller/drop/:id/:droppedClass/:droppedID', :action => 'drop'
  map.trash '/:controller/trash/:id', :action => 'trash'

  map.connect ':controller/:action/:id'
  
end
