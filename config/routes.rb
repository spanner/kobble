ActionController::Routing::Routes.draw do |map|
                                
  map.home '', :controller => 'account', :action => 'index'

  map.login 'login', :controller => 'account', :action => 'login'
  map.logout 'logout', :controller => 'account', :action => 'logout'
  map.signup 'signup/:id', :controller => 'account', :action => 'signup'
  map.activate 'activate/:key', :controller => 'account', :action => 'activate'
  map.faq '/faq', :controller => 'account', :action => 'faq'
  map.background '/background', :controller => 'account', :action => 'background'
  map.blogentry '/blogentry/:id', :controller => 'account', :action => 'blogentry'
  map.blog '/blog', :controller => 'account', :action => 'blog'
  map.discussion '/discussion', :controller => 'account', :action => 'discussion'
  map.discussion '/questions', :controller => 'account', :action => 'questions'
  map.me '/me', :controller => 'account', :action => 'me'
  map.user '/users/:action/:id', :controller => 'users'

  map.connect ':controller/:action/:id'
  
end
