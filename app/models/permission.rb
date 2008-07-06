class Permission < ActiveRecord::Base

  acts_as_spoke :only => :undelete

  belongs_to :user
  belongs_to :collection
  named_scope :activated, { :select => "active > 0" }

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

end

