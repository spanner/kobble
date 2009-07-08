class Permission < ActiveRecord::Base

  is_material :only => :undelete    # so that user on restoration gets the right permissions

  belongs_to :user
  belongs_to :collection
  named_scope :activated, { :select => "active > 0" }
  after_create :activate_if_trusted
  
  def activate
    self.active = true
  end
  
  def deactivate
    self.active = false
  end

  def activate!
    active = true
    save!
  end
  
  def deactivate!
    active = false
    save!
  end


protected
  
  def activate_if_trusted
    self.active = self.collection.public?
    self.save if self.changed?
  end
  
end

