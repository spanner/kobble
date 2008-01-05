class Padding < ActiveRecord::Base
  belongs_to :scratchpad
  belongs_to :padded, :polymorphic => true
  acts_as_list :scope => :scratchpad 
end
