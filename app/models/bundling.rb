class Bundling < ActiveRecord::Base
  
  acts_as_spoke :only => :undelete
  
  belongs_to :superbundle, :class_name => 'Bundle', :foreign_key => 'superbundle_id'
  belongs_to :member, :polymorphic => true
  named_scope :of, lambda {|object| { :conditions => {:member_type => object.class.to_s, :member_id => object.id} } }
end
