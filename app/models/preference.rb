class Preference < ActiveRecord::Base

  acts_as_spoke :only => [:owners]
  
  has_many :user_preferences, :dependent => :destroy
  has_many :users, :through => :user_preferences, :conditions => ['user_preferences.active = ?', true], :source => :user

end

