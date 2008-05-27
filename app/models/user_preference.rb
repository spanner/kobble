class UserPreference < ActiveRecord::Base

  belongs_to :user
  belongs_to :preference

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

