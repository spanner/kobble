class Activation < ActiveRecord::Base

  is_material :only => :undelete
  belongs_to :user
  belongs_to :collection

  def activate
    update_attribute :active, true
  end
  
  def deactivate
    update_attribute :active, false
  end
  
end

