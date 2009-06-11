require 'rubygems'
gem 'mislav-will_paginate'
require 'kobble'
require 'kobble/exceptions'
require 'kobble/string_extensions'
require 'kobble/aap_extensions'
require 'kobble/response'
# require 'kobble/catcher'
require 'kobble/kore'

String.send :include, Kobble::StringExtensions
ActiveRecord::Base.send :include, Kobble::AapExtensions
ActiveRecord::Base.send :include, Kobble::Catcher
ActiveRecord::Base.send :include, Kobble::Kore
