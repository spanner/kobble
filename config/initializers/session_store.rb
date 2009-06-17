ActionController::Base.session = {
  :key => '_kobble', 
  :secret => '3027a9ff8b68e6c62aed475bee95555d'
}

ActionController::Dispatcher.middleware.use FlashSessionCookieMiddleware, ActionController::Base.session_options[:key]
