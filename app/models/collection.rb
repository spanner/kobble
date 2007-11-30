class Collection < ActiveRecord::Base

  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :blog_forum, :class_name => 'Forum', :foreign_key => 'blog_forum_id'
  belongs_to :editorial_forum, :class_name => 'Forum', :foreign_key => 'editorial_forum_id'

  has_many :users, :order => 'lastname, firstname', :dependent => :nullify
  
  has_many :user_groups, :order => 'name', :dependent => :destroy
  has_many :bundles, :order => 'name', :dependent => :destroy
  has_many :sources, :order => 'name', :dependent => :destroy
  has_many :nodes, :order => 'name', :dependent => :destroy
  has_many :surveys, :dependent => :destroy
  has_many :questions, :order => 'name', :dependent => :destroy
  has_many :blogentries, :order => 'date DESC', :dependent => :destroy
  has_many :occasions, :order => 'name', :dependent => :destroy
  has_many :forums, :order => 'name', :dependent => :destroy
  has_many :topics, :order => 'name', :dependent => :destroy
  has_many :posts, :order => 'date DESC', :dependent => :destroy
  has_many :tags, :order => 'name ASC', :dependent => :destroy
  
  cattr_accessor :current_collection
  
  def allows_registration?
    allow_registration > 0
  end
end
