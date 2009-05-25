class Scratchpad < ActiveRecord::Base

  is_material :only => [:owners, :undelete]
  has_many :paddings, :dependent => :destroy

  def scraps
    paddings.map{ |p| p.scrap }
  end
  
  def catch_this(object)
    if self.paddings.of(object).empty?
      paddings.create!(:scrap => object)
      return Material::CatchResponse.new("#{object.name} added to #{self.name} scratchpad", 'copy', 'success')
    else
      return Material::CatchResponse.new("#{self.name} already contains #{object.name}", '', 'failure')
    end
  end

  def drop_this(object)
    paddings.delete(self.paddings.of(object))
    return Material::CatchResponse.new("#{object.name} removed from #{self.name} scratchpad", 'delete', 'success')
  end

end
