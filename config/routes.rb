ActionController::Routing::Routes.draw do |map|
                                
  map.home '', :controller => 'account', :action => 'index'

  map.login 'login', :controller => 'account', :action => 'login'
  map.logout 'logout', :controller => 'account', :action => 'logout'
  
  map.catch '/:controller/catch/:id/:caughtClass/:caughtID', :action => 'catch'
  map.drop '/:controller/drop/:id/:droppedClass/:droppedID', :action => 'drop'
  map.trash '/:controller/trash/:id', :action => 'trash'

  map.connect ':controller/:action/:id'
  
end
