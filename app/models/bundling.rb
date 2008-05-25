class Bundling < ActiveRecord::Base
  belongs_to :superbundle, :class_name => 'Bundle', :foreign_key => 'superbundle_id'
  belongs_to :member, :polymorphic => true
  has_finder :of, lambda {|object| { :conditions => {:member_type => object.class.to_s, :member_id => object.id} } }
end
