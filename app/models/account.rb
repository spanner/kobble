class Account < ActiveRecord::Base

  acts_as_spoke :only => [:log, :illustration, :discussion, :owners]
  belongs_to :user
  has_many :users, :order => 'name'
  has_many :collections, :order => 'name'
  has_many :tags
  has_many :events do
    def recent
      find(:all, :limit => 10, :order => 'at DESC')
    end
    def latest
      find(:first, :order => 'at DESC')
    end
  end
  
  def self.nice_title
    "account"
  end

  def collections_by_activity 
    self.collections.find(:all, :order => 'last_active_at DESC')
  end
  
  def users_by_activity 
    self.users.find(:all, :order => 'last_active_at DESC')
  end
  
end
