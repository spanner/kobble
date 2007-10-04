class OffendersWarning < ActiveRecord::Base
  belongs_to :warning
  belongs_to :offender, :polymorphic => true
end
