# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
# RAILS_GEM_VERSION = '2.1.1'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'mime/types'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here

  config.gem "authlogic"
  
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += %W( #{RAILS_ROOT}/app/middleware )
  
  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # session setup has its own initializer
  # in initializers/session_store.rb

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  config.active_record.observers = :edit_observer, :post_observer, :topic_observer

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
  
  config.plugins = [:all, :gravtastic, :kobble]
  
  config.action_view.field_error_proc = Proc.new do |html_tag, instance_tag| 
    %{<span class="errordetail">#{html_tag}</span>}
  end
  
end
