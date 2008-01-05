class Flagging < ActiveRecord::Base
  belongs_to :flag
  belongs_to :flaggable, :polymorphic => true
end
