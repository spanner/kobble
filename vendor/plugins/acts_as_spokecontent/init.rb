$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'active_record/acts/spoke_content'
ActiveRecord::Base.class_eval { include ActiveRecord::Acts::SpokeContent }
