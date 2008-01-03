class Bundling < ActiveRecord::Base
  belongs_to :bundle
  belongs_to :bundled, :polymorphic => true
  acts_as_list :scope => :bundle 
end

