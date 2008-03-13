class Flag < ActiveRecord::Base
  acts_as_spoke :except => :illustration
  #has_many_polymorphs :flaggables, :from => self.organised_classes(:except => :flags), :through => :flaggings
end
