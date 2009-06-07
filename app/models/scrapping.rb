class Scrapping < ActiveRecord::Base

  is_material :only => [:owners, :collection]
  belongs_to :scrap, :polymorphic => true
  acts_as_list :scope => :created_by
  before_save :get_collection_from_scrap
  
  named_scope :of, lambda {|object| { :conditions => {:scrap_type => object.class.to_s, :scrap_id => object.id} } }
  
  def get_collection_from_scrap
    self.collection_id = self.scrap.collection_id
  end
  
end
