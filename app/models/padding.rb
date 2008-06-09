class Padding < ActiveRecord::Base

  belongs_to :scratchpad
  belongs_to :scrap, :polymorphic => true
  acts_as_list :scope => :scratchpad 
  
  named_scope :of, lambda {|object| { :conditions => {:scrap_type => object.class.to_s, :scrap_id => object.id} } }
  
end
