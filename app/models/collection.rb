class Collection < ActiveRecord::Base

  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by'

  has_many :users
  has_many :bundles
  has_many :sources
  has_many :nodes
  
end
