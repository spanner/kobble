class Collection < ActiveRecord::Base

  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :blog_forum, :class_name => 'Forum', :foreign_key => 'blog_forum_id'
  belongs_to :editorial_forum, :class_name => 'Forum', :foreign_key => 'editorial_forum_id'

  has_many :users, :order => 'lastname, firstname'
  has_many :bundles
  has_many :sources
  has_many :nodes
  has_many :surveys
  has_many :questions
  has_many :blogentries
  has_many :occasions
  has_many :forums
  has_many :topics
  has_many :posts
  
  cattr_accessor :current_collection
  
  def allows_registration?
    allow_registration > 0
  end
end
