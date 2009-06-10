class Marker < ActiveRecord::Base

  # set_table_name :scrappings        # for migration
  
  is_material :only => [:owners, :collection]
  belongs_to :selection, :polymorphic => true
  acts_as_list :scope => :created_by
  before_save :get_collection
  
  named_scope :of, lambda {|object| { :conditions => {:selection_type => object.class.to_s, :selection_id => object.id} } }
  
  def get_collection
    self.collection_id = self.selection.collection_id
  end
  
end
