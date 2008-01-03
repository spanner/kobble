class MembersSuperbundle < ActiveRecord::Base
  belongs_to :superbundle, :class_name => 'Bundle', :foreign_key => 'superbundle_id'
  belongs_to :member, :polymorphic => true
  acts_as_list :scope => :superbundle 
end

