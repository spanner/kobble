class Collection < ActiveRecord::Base

  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'

  has_many :users, :order => 'lastname, firstname'
  has_many :bundles
  has_many :sources
  has_many :nodes
  
  cattr_accessor :current_collection
  
end
