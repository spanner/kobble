$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'active_record/acts/spokecontent'
ActiveRecord::Base.class_eval { include ActiveRecord::Acts::Spokecontent }
