class Bundling < ActiveRecord::Base
  
  is_material :only => :undelete
  
  belongs_to :superbundle, :class_name => 'Bundle', :foreign_key => 'superbundle_id'
  belongs_to :member, :polymorphic => true
  acts_as_list :scope => :superbundle_id
  
  named_scope :of, lambda {|object| { :conditions => {:member_type => object.class.to_s, :member_id => object.id} } }
  named_scope :in, lambda {|bundle| { :conditions => {:superbundle_id => bundle.id} } }
end
