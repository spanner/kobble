class Flag < ActiveRecord::Base
  acts_as_spoke :except => [:collection, :illustration, :index, :discussion]
  has_many_polymorphs :flaggables, :from => Spoke::Config.content_models, :through => :flaggings
end
