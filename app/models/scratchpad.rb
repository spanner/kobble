class Scratchpad < ActiveRecord::Base

  is_material :only => [:owners, :undelete]
  has_many :paddings, :dependent => :destroy

  def scraps
    paddings.map{ |p| p.scrap }
  end
  
end
