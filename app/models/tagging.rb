class Tagging < ActiveRecord::Base

  belongs_to :tag
  belongs_to :taggable, :polymorphic => true, :dependent => :destroy
  named_scope :of, lambda {|object| { :conditions => {:taggable_type => object.class.to_s, :taggable_id => object.id} } }
end
