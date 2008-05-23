class Scratchpad < ActiveRecord::Base

  acts_as_spoke :only => [:owners]
  has_many :paddings, :dependent => :destroy

  def scraps
    paddings.map{ |p| p.scrap }
  end
  
  def catch(object)
    self.paddings.create(:scrap => object)
  end

  def drop(object)
    self.paddings.delete(:scrap => object)
  end

end
