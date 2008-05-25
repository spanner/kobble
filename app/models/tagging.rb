class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true, :dependent => :destroy
  has_finder :of, lambda {|object| { :conditions => {:taggable_type => object.class.to_s, :taggable_id => object.id} } }
end
