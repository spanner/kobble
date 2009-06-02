require 'digest/sha1'
include EmailColumn

class User < ActiveRecord::Base
  cattr_accessor :current

  attr_protected :activated_at
  attr_accessor :password_confirmation
  attr_accessor :old_password
  attr_accessor :notify_of_login
  attr_accessor :newly_activated

  before_create :make_activation_code
  before_save :encrypt_password
  before_destroy :reassign_associates

  is_material :except => [:collection, :index, :discussion, :annotation, :selection]
  
  belongs_to :account
  belongs_to :person
  
  has_many :permissions, :dependent => :destroy
  has_many :permitted_collections, :through => :permissions, :conditions => ['permissions.active = ?', true], :source => :collection
  # has_many :activations, :dependent => :destroy
  # has_many :collections, :through => :activations, :conditions => ['activations.active = ?', true], :source => :collection
  has_many :monitorships, :dependent => :destroy
  has_many :monitored_topics, :through => :monitorships, :conditions => ['monitorships.active = ?', true], :order => 'topics.replied_at desc', :source => :topic
  has_many :user_preferences, :dependent => :destroy
  has_many :preferences, :through => :user_preferences, :conditions => ['user_preferences.active = ?', true], :source => :preference

  has_many :created_collections, :class_name => 'Collection', :foreign_key => 'created_by', :dependent => :destroy
  has_many :created_sources, :class_name => 'Source', :foreign_key => 'created_by', :dependent => :destroy
  has_many :created_nodes, :class_name => 'Node', :foreign_key => 'created_by', :dependent => :destroy
  has_many :created_bundles, :class_name => 'Bundle', :foreign_key => 'created_by', :dependent => :destroy
  has_many :created_topics, :class_name => 'Topic', :foreign_key => 'created_by', :dependent => :destroy
  has_many :created_posts, :class_name => 'Post', :foreign_key => 'created_by', :dependent => :destroy  
  has_many :created_scratchpads, :class_name => 'Scratchpad', :foreign_key => 'created_by', :dependent => :destroy
  has_many :created_tags, :class_name => 'Tag', :foreign_key => 'created_by', :dependent => :destroy
  has_many :created_taggings, :class_name => 'Tagging', :foreign_key => 'created_by', :dependent => :nullify
  has_many :events, :order => 'at DESC', :dependent => :nullify

  named_scope :in_account, lambda { |account| {:conditions => { :account_id => account.id }} }

  email_column :email
  validates_presence_of     :name
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_presence_of     :password, :if => :password_required?
  validates_confirmation_of :password,  :if => :password_supplied?
  validates_length_of       :password, :within => 4..40, :if => :password_supplied?

  def self.nice_title
    "user"
  end

  def scratchpads
    if self.created_scratchpads.empty?
      ['a scratchpad', 'another scratchpad', 'miscellaneous', 'other'].each do |name|
        self.created_scratchpads.create({:name => name})
      end
    end
    self.created_scratchpads
  end

  def can_login?
    status > 0 and !login.nil? and login != '' and !email.nil?
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
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.

  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]
    return nil unless u && u.authenticated?(password)
    u.password = nil if u.previously_logged_in_at   # once they've logged in twice we forget it
    u.previously_logged_in_at = u.logged_in_at
    u.logged_in_at = Time.now.utc
    u.save!
    u
  end

  def activate
    self.status = 10
    self.logged_in_at = self.activated_at = Time.now.utc
    self.activation_code = nil
    # self.password = nil
    self.save!
  end

  def deactivate
    @activated = false
    self.status = 0
    self.save!
  end
  
  # did they activate within the last five minutes?
  def recently_activated?
    return false unless activated?
    (Time.now - activated_at) <= 300
  end

  def activated?
    activated_at != nil
  end

  def inactive?
    activated_at == nil
  end
  
  def status_in_words
    return "not yet activated" if inactive?
    return "deleted" if deleted?
    return "site developer" if developer?
    return "site admin" if admin?
    return "account holder" if account_holder?
    return "account administrator" if account_admin?
    return "normal user"
  end
  
  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    logger.warn("!!!! testing password #{password} for user #{name}")
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 4.weeks.from_now.utc
    self.remember_token = encrypt("#{login}--#{remember_token_expires_at}")
    save(false)
    { :value => self.remember_token, :expires => self.remember_token_expires_at }
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
    
  def best_name
    self.diminutive.blank? ? self.name : self.diminutive
  end
  
  def provisional_new_password
    self.new_password = generate_password(12)
    self.make_activation_code
    self.save!
    self.new_password
  end
  
  def accept_new_password(newpass=nil)
    self.password = self.new_password
    self.new_password = nil
    self.crypted_password = nil
    self.activation_code = nil
    self.last_login = Time.now.utc
    self.save!
  end
  
  def tags_with_popularity
    taggings = self.created_taggings.grouped_with_popularity
    taggings.each {|t| t.tag.used = t.use_count }
    taggings.map {|t| t.tag }.uniq.sort{|a,b| a.name <=> b.name}
  end
  
  def collections_available
    account_admin? ? self.account.collections : self.permitted_collections
  end
  
  def activate_available_collections
    self.permitted_collections.each { |collection| activation_of(collection).activate }
  end
  
  public
  
    def self.everything_monitors
      []
    end
  
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

    def using_collection? (collection)
      collections.include?(collection)
    end

    def activation_of (collection)
      Activation.find_or_create_by_user_id_and_collection_id(self.id, collection.id)
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
    
  protected
  
    # before filter 
    def encrypt_password
      return if password.blank?      
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank?
    end
    
    def password_supplied?
      !password.blank?
    end

    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end

    def generate_password(length=8)
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("1".."9").to_a
      Array.new(length, '').collect{chars[rand(chars.size)]}.join
    end

    def self.reassignable_associations
      [:created_collections, :created_sources, :created_nodes, :created_bundles, :created_tags]
    end

end
