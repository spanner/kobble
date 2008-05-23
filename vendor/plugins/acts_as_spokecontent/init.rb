$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'spoke/class_extensions'
require 'spoke/associations'

require 'active_record/catches'
ActiveRecord::Base.class_eval { include ActiveRecord::Catches }

require 'active_record/acts/spoke_content'
ActiveRecord::Base.class_eval { include ActiveRecord::Acts::SpokeContent }


