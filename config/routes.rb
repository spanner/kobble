ActionController::Routing::Routes.draw do |map|
                                
  map.home '', :controller => 'account', :action => 'welcome'

  map.resources :users, :member => { :admin => :post } do |user|
    user.resources :moderators
  end

  map.resources :forums do |forum|
    forum.resources :topics, :name_prefix => nil do |topic|
      topic.resources :posts, :name_prefix => nil
      topic.resource :monitorship, :controller => :monitorships, :name_prefix => nil
    end
  end

  map.resources :posts, :name_prefix => 'all_', :collection => { :search => :get }

  %w(user forum).each do |attr|
    map.resources :posts, :name_prefix => "#{attr}_", :path_prefix => "/#{attr.pluralize}/:#{attr}_id"
  end

  map.with_options :controller => 'posts', :action => 'monitored' do |map|
    map.formatted_monitored_posts 'users/:user_id/monitored.:format'
    map.monitored_posts           'users/:user_id/monitored'
  end

  map.login 'login', :controller => 'account', :action => 'login'
  map.logout 'logout', :controller => 'account', :action => 'logout'
  map.signup 'signup/:id', :controller => 'account', :action => 'signup'
  map.activate 'activate/:key', :controller => 'account', :action => 'activate'
  map.faq '/faq', :controller => 'account', :action => 'faq'
  map.background '/background', :controller => 'account', :action => 'background'
  map.blog '/blog', :controller => 'blogentries', :action => 'index'
  map.discussion '/discussion', :controller => 'forums', :action => 'index'

  map.connect ':controller/:action/:id'
  
end
