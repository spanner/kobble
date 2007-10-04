class MarksTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :mark, :polymorphic => true
end
