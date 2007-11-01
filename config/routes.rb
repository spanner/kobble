ActionController::Routing::Routes.draw do |map|
                                
  map.home '', :controller => 'account', :action => 'index'

  # map.forum 'discussion/forum/:id', :controller => 'forums', :action => 'show'
  # map.forums 'discussion/forum', :controller => 'forums', :action => 'index'
  # map.topic 'discussion/topic/:id', :controller => 'topics', :action => 'show'
  # map.topics 'discussion/topics', :controller => 'topics', :action => 'index'

  map.resources :forums do |forum|
    forum.resources :topics, :name_prefix => nil do |topic|
      topic.resources :posts, :name_prefix => nil
      # topic.resource :monitorship, :controller => :monitorships, :name_prefix => nil
    end
  end
  map.resources :posts, :name_prefix => 'all_', :collection => { :search => :get }

  # how i hate restful rails
  # but it's easier to carry on using the beast routes and just add a few more 
  # to get round the deep rubbishness of the :method hack

  map.delete_post '/forum/:forum_id/topic/:topic_id/posts/:id;delete', :controller => 'posts', :action => 'destroy'
  map.delete_topic '/forum/:forum_id/topic/:id;delete', :controller => 'topics', :action => 'destroy'
  map.update_post '/forum/:forum_id/topic/:topic_id/posts/:id;update', :controller => 'posts', :action => 'update'
  map.update_topic '/forum/:forum_id/topic/:id;update', :controller => 'posts', :action => 'update'

  map.discussion '/discussion', :controller => 'account', :action => 'discussion'
  map.conversation '/conversation', :controller => 'account', :action => 'conversation'

  map.blogentry '/blogentry/:id', :controller => 'account', :action => 'blogentry'
  map.blog '/blog', :controller => 'account', :action => 'blog'

  map.login 'login', :controller => 'account', :action => 'login'
  map.logout 'logout', :controller => 'account', :action => 'logout'
  map.signup 'signup/:id', :controller => 'account', :action => 'signup'
  map.activate 'activate/:key', :controller => 'account', :action => 'activate'

  map.faq '/faq', :controller => 'account', :action => 'faq'
  map.background '/background', :controller => 'account', :action => 'background'
  map.questions '/survey', :controller => 'account', :action => 'survey'
  map.me '/me', :controller => 'account', :action => 'me'
  map.user '/users/:action/:id', :controller => 'users'

  map.connect ':controller/:action/:id'
  
end
