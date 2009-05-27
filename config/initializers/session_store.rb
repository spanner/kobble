ActionController::Base.session = {
  :key     => '_materialist',
  :secret  => '--That of which we cannot speak we must pass over in silence.--'
}

ActionController::Dispatcher.middleware.use FlashSessionCookieMiddleware, ActionController::Base.session_options[:key]
