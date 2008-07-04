class Annotation < ActiveRecord::Base

  acts_as_spoke :only => [:owners, :index, :log, :undelete]
  
  belongs_to :annotation_type
  belongs_to :annotated, :polymorphic => true
  named_scope :of, lambda {|object| { :conditions => {:annotated_type => object.class.to_s, :annotated_id => object.id} } }
  named_scope :of_type, lambda {|type| { :conditions => {:annotation_type => AnnotationType.find_by_name(type) } } }
  named_scope :important, { :conditions => {:important => true} }

  named_scope :bad, {
    :select => 'annotations.*',
    :conditions => "annotation_types.badnews = 1",
    :joins => "INNER JOIN annotation_types on annotations.annotation_type_id = annotation_types.id"
  }

  named_scope :good, {
    :select => 'annotations.*',
    :conditions => "annotation_types.goodnews = 1",
    :joins => "INNER JOIN annotation_types on annotations.annotation_type_id = annotation_types.id"
  }
  
  validates_presence_of :annotation_type

  def self.nice_title
    "annotation"
  end
  
  def name
    self.annotated ? "annotation of #{self.annotated.name}" : 'loose annotation'
  end
  
  def badnews?
    annotation_type.badnews?
  end

  def goodnews?
    annotation_type.goodnews?
  end
  
end
