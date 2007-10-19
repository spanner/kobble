ActionController::Routing::Routes.draw do |map|
                              
  map.connect ':controller/service.wsdl',
    :action => 'wsdl'

  map.connect ':controller/for/:name',
    :action => 'for'

  map.connect ':controller/:action/:id'

  map.connect '/faq', :controller => 'account', :action => 'faq'
  map.connect '/background', :controller => 'account', :action => 'background'
  map.connect '', :controller => 'account', :action => 'index'

end
