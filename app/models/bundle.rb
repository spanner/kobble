class Bundle < ActiveRecord::Base

  has_many :bundlings, :dependent => :destroy, :as => 'superbundle'
  has_many_polymorphs :members, :as => 'superbundle', :from => Spoke::Config.content_models, :through => :bundlings, :dependent => :destroy
  acts_as_spoke
  acts_as_catcher :members
  
  def self.nice_title
    "set"
  end
end

