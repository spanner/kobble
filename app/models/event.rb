class Event < ActiveRecord::Base

  belongs_to :account
  belongs_to :collection
  belongs_to :user
  belongs_to :affected, :polymorphic => true

  has_finder :since, lambda {|start| { :conditions => ['at > ?', start] } }
  has_finder :creations, :conditions => {:event_type => 'created'}
  has_finder :updates, :conditions => {:event_type => 'updated'}
  has_finder :deletions, :conditions => {:event_type => 'deleted'}  
  has_finder :latest, :limit => 5, :order => 'at DESC'
  
end
