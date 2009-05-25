class AnnotationType < ActiveRecord::Base

  is_material :only => [:owners, :undelete]
  
  has_many :annotations
  named_scope :bad, { :conditions => {:badnews => true} }
  named_scope :good, { :conditions => {:goodnews => true} }
  
end
