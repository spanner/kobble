class Flagging < ActiveRecord::Base

  acts_as_spoke :only => :undelete
  belongs_to :flag
  belongs_to :flaggable, :polymorphic => true
  named_scope :of, lambda {|object| { :conditions => {:flaggable_type => object.class.to_s, :flaggable_id => object.id} } }

end
