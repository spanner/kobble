class Account < ActiveRecord::Base
  cattr_accessor :current

  is_material :only => [:illustration, :owners]
  
  belongs_to :user
  belongs_to :account_type
  has_many :users, :order => 'name', :dependent => :destroy
  authenticates_many :user_sessions
  
  has_many :collections, :order => 'name', :dependent => :destroy
  has_many :tags, :dependent => :destroy
  has_many :events, :order => 'at DESC', :dependent => :destroy
  
  validates_presence_of :name, :user, :account_type, :subdomain
  validates_format_of :subdomain, :with => /^[A-Za-z0-9-]+$/, :message => 'The subdomain can only contain alphanumeric characters and dashes.', :allow_blank => true
  validates_uniqueness_of :subdomain, :case_sensitive => false
  validates_exclusion_of :subdomain, :in => %w( support blog www billing help api get discuss about faq ), :message => "The subdomain <strong>{{value}}</strong> is reserved and unavailable."

  before_validation :downcase_subdomain
  
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

  def can_have_discussion?
    can_have_users?
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
  
protected

  def downcase_subdomain
    self.subdomain.downcase! if attribute_present?("subdomain")
  end
  
end
