# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.1'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
#require 'spoke_config'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  config.active_record.observers = :edit_observer, :user_observer, :post_observer, :topic_observer, :permission_observer

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
  
end

require 'will_paginate'

ExceptionNotifier.sender_address = "sysadmin@spanner.org"
ExceptionNotifier.exception_recipients = "will@spanner.org"
ExceptionNotifier.email_prefix = "[m.st] "

Ultrasphinx::Search.excerpting_options = HashWithIndifferentAccess.new({
  :before_match => '<strong>',
  :after_match => '</strong>',
  :chunk_separator => "...",
  :limit => 256,
  :around => 3,
  :content_methods => [['name'], ['body', 'description', 'extracted_text'], ['field_notes']]
})

Ultrasphinx::Search.client_options[:with_subtotals] = true
Ultrasphinx::Search.client_options[:with_global_rank] = true


