class Flagging < ActiveRecord::Base
  belongs_to :flag
  belongs_to :flaggable, :polymorphic => true
  has_finder :of, lambda {|object| { :conditions => {:flaggable_type => object.class.to_s, :flaggable_id => object.id} } }
end
