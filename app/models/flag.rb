class Flag < ActiveRecord::Base
  acts_as_spoke :except => [:collection, :illustration, :index, :description]
  has_many :flaggings, :dependent => :destroy

  def flagged_items
    flaggings.map{ |f| f.flaggable }
  end

end
