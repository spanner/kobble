class Bookmarking < ActiveRecord::Base

  # set_table_name :scrappings        # for migration
  
  is_material :only => [:owners, :collection]
  belongs_to :bookmark, :polymorphic => true
  acts_as_list :scope => :created_by
  before_save :get_collection
  
  named_scope :of, lambda {|object| { :conditions => {:bookmark_type => object.class.to_s, :bookmark_id => object.id} } }
  
  def get_collection
    self.collection_id = self.bookmark.collection_id
  end
  
end
