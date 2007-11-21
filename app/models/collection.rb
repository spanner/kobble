class Collection < ActiveRecord::Base

  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :blog_forum, :class_name => 'Forum', :foreign_key => 'blog_forum_id'
  belongs_to :editorial_forum, :class_name => 'Forum', :foreign_key => 'editorial_forum_id'

  has_many :users, :order => 'lastname, firstname', :dependent => :nullify
  
  has_many :user_groups, :dependent => :destroy
  has_many :bundles, :dependent => :destroy
  has_many :sources, :dependent => :destroy
  has_many :nodes, :dependent => :destroy
  has_many :surveys, :dependent => :destroy
  has_many :questions, :dependent => :destroy
  has_many :blogentries, :dependent => :destroy
  has_many :occasions, :dependent => :destroy
  has_many :forums, :dependent => :destroy
  has_many :topics, :dependent => :destroy
  has_many :posts, :dependent => :destroy
  
  cattr_accessor :current_collection
  
  def allows_registration?
    allow_registration > 0
  end
end
