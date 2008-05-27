class Annotation < ActiveRecord::Base

  acts_as_spoke :only => [:owners, :index]
  
  belongs_to :annotation_type
  belongs_to :annotated, :polymorphic => true
  has_finder :of, lambda {|object| { :conditions => {:annotated_type => object.class.to_s, :annotated_id => object.id} } }
  has_finder :of_type, lambda {|type| { :conditions => {:annotation_type => AnnotationType.find_by_name(type) } } }

  def self.nice_title
    "annotation"
  end

end
