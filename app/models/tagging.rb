class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true, :dependent => :destroy

  has_finder :in_collection, lambda { |account| {:conditions => { :account_id => account.id }} }


end
