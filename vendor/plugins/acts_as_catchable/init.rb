require 'acts_as_catchable'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Catchable)
