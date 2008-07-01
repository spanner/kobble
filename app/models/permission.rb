class Permission < ActiveRecord::Base
  belongs_to :user
  belongs_to :collection
  named_scope :activated, { :select => "active > 0" }

  def activate
    self.active = true
  end
  
  def deactivate
    self.active = false
  end
  
  def is_active?
    self.active
  end
end

