class Annotation < ActiveRecord::Base

  acts_as_spoke :only => [:owners, :index]
  belongs_to :annotation_type
  belongs_to :annotated, :polymorphic => true
  has_finder :of, lambda {|object| { :conditions => {:annotated_type => object.class.to_s, :annotated_id => object.id} } }
  
  def self.nice_title
    "annotation"
  end

end
