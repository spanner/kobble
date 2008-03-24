class Activation < ActiveRecord::Base
  belongs_to :user
  belongs_to :collection

  def activate
    self.active = true
  end
  
  def deactivate
    self.active = false
  end
  
  def is_active?
    self.active > 0
  end
end

