class AnnotationType < ActiveRecord::Base

  acts_as_spoke :only => [:owners]
  has_many :annotations
  
end
