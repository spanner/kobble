class ScrapsScratchpad < ActiveRecord::Base
  belongs_to :scratchpad
  belongs_to :scrap, :polymorphic => true
  acts_as_list :scope => :scratchpad 
end
