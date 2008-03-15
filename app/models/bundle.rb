class Bundle < ActiveRecord::Base

  has_many_polymorphs :members, :as => 'superbundle', :from => self.organised_classes, :through => :bundlings, :dependent => :destroy
  acts_as_catcher :members
  acts_as_spoke

  def self.nice_title
    "set"
  end
end

