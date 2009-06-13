class User < ActiveRecord::Base
  cattr_accessor :current

  acts_as_authentic do |config|
    config.validations_scope = :account_id
    config.transition_from_restful_authentication = true
  end
  
  is_material :only => [:owners, :illustration, :log, :undelete]
  is_gravtastic

  belongs_to :account
  belongs_to :person
  
  has_many :permissions, :dependent => :destroy
  has_many :permitted_collections, :through => :permissions, :conditions => ['permissions.active = ?', true], :order => 'collections.name', :source => :collection
  has_many :monitorships, :dependent => :destroy
  has_many :monitored_topics, :through => :monitorships, :conditions => ['monitorships.active = ?', true], :order => 'topics.replied_at desc', :source => :topic
  has_many :user_preferences, :dependent => :destroy
  has_many :preferences, :through => :user_preferences, :conditions => ['user_preferences.active = ?', true], :source => :preference

  has_many :created_collections, :class_name => 'Collection', :foreign_key => 'created_by_id', :dependent => :destroy
  has_many :created_sources, :class_name => 'Source', :foreign_key => 'created_by_id', :dependent => :destroy
  has_many :created_nodes, :class_name => 'Node', :foreign_key => 'created_by_id', :dependent => :destroy
  has_many :created_bundles, :class_name => 'Bundle', :foreign_key => 'created_by_id', :dependent => :destroy
  has_many :created_topics, :class_name => 'Topic', :foreign_key => 'created_by_id', :dependent => :destroy
  has_many :created_posts, :class_name => 'Post', :foreign_key => 'created_by_id', :dependent => :destroy  
  has_many :created_tags, :class_name => 'Tag', :foreign_key => 'created_by_id', :dependent => :destroy
  has_many :created_taggings, :class_name => 'Tagging', :foreign_key => 'created_by_id', :dependent => :nullify
  has_many :events, :order => 'at DESC', :dependent => :nullify
  
  # simplified scratchpad relationship
  # polymorphic. we can't go :through so see 'bookmarks' below

  has_many :bookmarkings, :foreign_key => 'created_by_id', :order => 'position', :dependent => :destroy

  # and the old one is kept for transition but soon to be removed
  
  has_many :created_scratchpads, :class_name => 'Scratchpad', :foreign_key => 'created_by_id', :dependent => :destroy

  named_scope :in_account, lambda { |account| {:conditions => { :account_id => account.id }} }

  after_create :send_welcome
  before_destroy :reassign_associates
  before_validation :set_login_if_blank
  
  def self.nice_title
    "user"
  end

  #! reinstate activation machinery

  def inactive?
    false
  end

  def account_admin?
    status >= 100
  end

  def admin?
    status >= 200
  end
  
  def developer?
    status >= 300
  end
  
  def account_holder?
    account.user == self
  end
  
  def is_trusted?
    account_admin? || account_holder? || trusted
  end

  def recently_activated?
    return false unless activated?
    (Time.now - activated_at) <= 5.minutes
  end

  def best_name
    self.diminutive.blank? ? self.name : self.diminutive
  end
    
  def tags_with_popularity
    taggings = self.created_taggings.grouped_with_popularity
    taggings.each {|t| t.tag.used = t.use_count }
    taggings.map {|t| t.tag }.uniq.sort{|a,b| a.name <=> b.name}
  end
  
  def collections_available
    account_admin? ? self.account.collections : self.permitted_collections
  end
  
public
  
  def self.currently_online
    User.find(:all, :conditions => ["last_seen_at > ?", Time.now.utc-5.minutes])
  end

  def has_permission? (collection)
    permitted_collections.include?(collection)
  end
  
  # the permission_observer sets default activation of permissions according to status of user and collection
  # in an after_create trigger so that defaults both positive and negative can be overridden
  
  def permission_for (collection)
    permission = Permission.find_or_create_by_user_id_and_collection_id(self.id, collection.id)
  end
  
  def all_permissions
    account.collections.map { |c| permission_for(c) }
  end

  def monitoring? (topic)
    monitorships.include?(topic)
  end

  def monitorship_of (topic)
    Monitorship.find_or_create_by_user_id_and_topic_id(self.id, topic.id)
  end

  def preference_for (preference)
    preference = Preference.find_by_abbr(preference) unless preference.class == Preference
    UserPreference.find_or_create_by_user_id_and_preference_id(self.id, preference.id)
  end
  
  def prefers? (abbr)
    preference = Preference.find_by_abbr(abbr)
    UserPreference.find_or_create_by_user_id_and_preference_id(self.id, preference.id).is_active?
  end
  
  # scratchpad/bookmark functions
  
  def bookmarks
    self.bookmarkings.map {|b| b.bookmark}
  end
    
  def current_bookmarkings(collection = Collection.current)
    self.bookmarkings.in_collection(collection)
  end

  def current_bookmarks(collection = Collection.current)
    self.current_bookmarkings(collection).map {|b| b.bookmark}
  end
  
protected

  def set_login_if_blank
    self.login = self.email if self.login.blank?
  end
  
  def self.reassignable_associations
    [:created_collections, :created_sources, :created_nodes, :created_bundles, :created_tags]
  end

  def send_welcome
    if self.record_timestamps
      if self == User.current
        UserNotifier.deliver_welcome(self)
      else
        UserNotifier.deliver_invitation(self, User.current)
      end
    end
  end

end


