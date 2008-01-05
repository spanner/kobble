class Flagging < ActiveRecord::Base
  belongs_to :flag
  belongs_to :flagged, :polymorphic => true
end
