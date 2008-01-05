class Scratchpad < ActiveRecord::Base
  acts_as_spoke :except => [:illustration, :discussion]
  has_many_polymorphs :scraps, :from => self.organised_classes(:except => :users), :through => :paddings

  # acts_as_catcher :scraps
end
