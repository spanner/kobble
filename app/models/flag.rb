class Flag < ActiveRecord::Base
  acts_as_spoke :except => [:collection, :illustration, :index, :description]
  has_many :flaggings, :dependent => :destroy

  def flagged
    flaggings.map{ |f| f.flaggable }
  end
  
  def catch_this(object)
    self.flaggings.create!(:flaggable => object) if self.flaggings.of(object).empty?
  end

  def drop_this(object)
    self.flaggings.delete(self.flaggings.of(object))
  end

end
