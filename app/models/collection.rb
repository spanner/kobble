class Collection < ActiveRecord::Base

  acts_as_spoke :except => [:collection, :index]
  belongs_to :account, :dependent => :destroy
  
  has_many :activations, :dependent => :destroy
  has_many :permissions, :dependent => :destroy
  has_many :users, :through => :permissions, :source => :user, :conditions => ['permissions.active = ?', true]
  has_many :sources, :order => 'name', :dependent => :destroy
  has_many :nodes, :order => 'name', :dependent => :destroy
  has_many :bundles, :order => 'name', :dependent => :destroy
  has_many :occasions, :order => 'name', :dependent => :destroy
  has_many :topics, :order => 'name', :dependent => :destroy

  has_many :events do
    def recent(since=nil)
      if (since.nil?)
        find(:all, :limit => 5, :order => 'at DESC')
      else
        find(:all, :conditions => ['at > ?', since], :order => 'at DESC')
      end
    end
    def latest
      find(:first, :order => 'at DESC')
    end
  end
  
  cattr_accessor :current_collections
 
end
