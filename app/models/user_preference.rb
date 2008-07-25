class UserPreference < ActiveRecord::Base

  belongs_to :user
  belongs_to :preference

  after_create :obey_default

  def activate
    self.active = true
  end
  
  def deactivate
    self.active = false
  end
  
  def is_active?
    self.active
  end
  
  def obey_default
    activate if preference.default_true?
  end
end

