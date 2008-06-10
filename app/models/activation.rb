class Activation < ActiveRecord::Base
  belongs_to :user
  belongs_to :collection

  def activate
    update_attribute :active, true
  end
  
  def deactivate
    update_attribute :active, false
  end
  
  def is_active?
    self.active > 0
  end
end

