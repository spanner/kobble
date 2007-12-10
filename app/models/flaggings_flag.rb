class FlaggingsFlag < ActiveRecord::Base
  belongs_to :flag
  belongs_to :flagging, :polymorphic => true
end
