class AnnotationType < ActiveRecord::Base

  acts_as_spoke :only => [:owners, :undelete]
  
  has_many :annotations
  
end
