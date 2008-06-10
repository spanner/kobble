class Account < ActiveRecord::Base

  acts_as_spoke :only => [:illustration, :discussion, :owners]
  
  belongs_to :user
  belongs_to :account_type
  has_many :users, :order => 'name', :dependent => :destroy
  has_many :collections, :order => 'name', :dependent => :destroy
  has_many :tags, :dependent => :destroy
  has_many :events, :order => 'at DESC'
  
  def self.nice_title
    "account"
  end

  def collections_by_activity 
    self.collections.find(:all, :order => 'last_active_at DESC')
  end
  
  def users_by_activity 
    self.users.find(:all, :order => 'last_active_at DESC')
  end
  
  def can_have_users?
    self.account_type.users_limit > 1
  end

  def can_have_audio?
    self.account_type.can_audio
  end

  def can_have_video?
    self.account_type.can_video
  end
  
  def can_add_user?
    self.account_type.users_limit > self.users.count
  end

  def can_add_collection?
    self.account_type.collections_limit > self.collections.count
  end
  
end
