class Collection < ActiveRecord::Base

  belongs_to :user
  has_and_belongs_to_many :users

  has_many :bundles
  has_many :sources
  has_many :people
  has_many :nodes
  
end
