class AnnotationType < ActiveRecord::Base

  acts_as_spoke :only => [:owners, :undelete]
  
  has_many :annotations
  named_scope :bad, { :conditions => {:badnews => true} }
  named_scope :good, { :conditions => {:goodnews => true} }
  
end
