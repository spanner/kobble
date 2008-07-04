class Tagging < ActiveRecord::Base

  acts_as_spoke :only => [:undelete, :owners]

  belongs_to :tag
  belongs_to :collection  # shortcut for collection cloud. collection link is set by tagging_observer
  belongs_to :taggable, :polymorphic => true
  
  named_scope :of, lambda {|object| { :conditions => {:taggable_type => object.class.to_s, :taggable_id => object.id} } }
  named_scope :in_collection, lambda { |collection| {:conditions => { :collection_id => collection.id }} }
  named_scope :in_collections, lambda { |collections| {:conditions => ["#{table_name}.collection_id in (" + collections.map{'?'}.join(',') + ")"] + collections.map { |c| c.id }} }
  named_scope :grouped_with_popularity, {
    :select => "taggings.*, count(taggings.id) as use_count", 
    :group => "taggings.tag_id", 
    :order => 'use_count DESC',
    :include => :tag
  }

end
