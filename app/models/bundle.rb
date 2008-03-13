class Bundle < ActiveRecord::Base

  acts_as_spoke
  has_many_polymorphs :members, :as => 'superbundle', :from => self.organised_classes, :through => :bundlings, :dependent => :destroy
  acts_as_catcher :members

  def self.nice_title
    "set"
  end
 
end

