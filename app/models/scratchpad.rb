class Scratchpad < ActiveRecord::Base

  acts_as_spoke :only => [:owners]
  has_many :paddings, :dependent => :destroy

  def scraps
    paddings.map{ |p| p.scrap }
  end
  
  def catch_this(object)
    if self.paddings.of(object).empty?
      paddings.create!(:scrap => object)
      return CatchResponse.new("#{object.name} added to #{self.name} scratchpad", 'copy', 'success')
    else
      return CatchResponse.new("#{self.name} already contains #{object.name}", '', 'failure')
    end
  end

  def drop_this(object)
    paddings.delete(self.paddings.of(object))
    return CatchResponse.new("#{object.name} removed from #{self.name} scratchpad", 'delete', 'success')
  end

end
