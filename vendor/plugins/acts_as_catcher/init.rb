require 'acts_as_catcher'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Catcher)
