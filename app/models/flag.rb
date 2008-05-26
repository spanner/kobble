class Flag < ActiveRecord::Base
  acts_as_spoke :except => [:collection, :illustration, :index, :description]
  has_many :flaggings, :dependent => :destroy

  def flagged
    flaggings.map{ |f| f.flaggable }
  end
  
  def catch_this(object)
    if self.flaggings.of(object).empty?
      self.flaggings.create!(:taggable => object)
      return CatchResponse.new("#{object.name} flagged with #{self.name}", 'copy', 'success')
    else
      return CatchResponse.new("#{self.name} already attached to #{object.name}", '', 'failure')
    end
  end

  def drop_this(object)
    self.flaggings.delete(self.flaggings.of(object))
    return CatchResponse.new("#{self.name} flag removed from #{object.name}", 'delete', 'success')
  end

end
