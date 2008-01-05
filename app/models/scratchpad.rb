class Scratchpad < ActiveRecord::Base
  acts_as_spoke

  has_many :paddings
  has_many :paddeds, :through => :paddings

  # acts_as_catcher :scraps
end
