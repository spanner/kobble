class Activation < ActiveRecord::Base
  belongs_to :user
  belongs_to :collection

  def activate
    self.active = true
  end
  
  def deactivate
    self.active = false
  end
  
end

