require 'rack/utils'

class FlashSessionCookieMiddleware
  def initialize(app, session_key = '_kobble', credentials_key = 'user_credentials')
    @app = app
    @session_key = session_key
    @credentials_key = credentials_key
  end

  def call(env)
    if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
      params = ::Rack::Utils.parse_query(env['QUERY_STRING'])

      unless params[@session_key].nil?
        kobble_cookie = [ @session_key, params[@session_key] ].join('=')
        credentials_cookie = [ @credentials_key, params[@credentials_key] ].join('=')
        env['HTTP_COOKIE'] = [kobble_cookie, credentials_cookie].join(';').freeze
      end
      STDERR.puts "middleware faking cookie to #{env['HTTP_COOKIE']}"
      
    end
    @app.call(env)
  end
end
