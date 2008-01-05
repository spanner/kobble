class Scratchpad < ActiveRecord::Base
  acts_as_spoke

  has_many_polymorphs :paddeds, :from => self.paddable, :through => :paddings

  # acts_as_catcher :scraps
end
