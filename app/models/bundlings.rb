class Membership < ActiveRecord::Base
  belongs_to :bundle
  belongs_to :member, :polymorphic => true
  acts_as_list :scope => :bundle 
end

