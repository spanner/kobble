class Collection < ActiveRecord::Base

  acts_as_spoke :except => [:collection, :index]
  belongs_to :user
  belongs_to :account
  
  has_many :active_collections, :dependent => :destroy
  has_many :users, :order => 'lastname, firstname', :dependent => :nullify
  has_many :sources, :order => 'name', :dependent => :destroy
  has_many :nodes, :order => 'name', :dependent => :destroy
  has_many :bundles, :order => 'name', :dependent => :destroy
  has_many :occasions, :order => 'name', :dependent => :destroy
  has_many :topics, :order => 'name', :dependent => :destroy
  has_many :posts, :order => 'date DESC', :dependent => :destroy
  has_many :tags, :order => 'name ASC', :dependent => :destroy
  
  cattr_accessor :current_collections
  
  def allows_registration?
    allow_registration > 0
  end
end
