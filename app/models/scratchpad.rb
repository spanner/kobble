class Scratchpad < ActiveRecord::Base
  acts_as_spoke :except => [:illustration, :discussion, :index]
  has_many_polymorphs :scraps, :from => Spoke::Config.content_models, :through => :paddings
  acts_as_catcher :scraps
end
