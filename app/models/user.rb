require 'digest/sha1'

class User < ActiveRecord::Base
  attr_protected :activated_at
  attr_accessor :password
  attr_accessor :password_confirmation
  attr_accessor :old_password

  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :collection      # for editors and higher this is a changeable value that indicates foreground collection. for readers it is fixed at signup

  has_many :sources, :class_name => 'Source', :foreign_key => 'speaker_id'
  has_many :nodes, :class_name => 'Node', :foreign_key => 'speaker_id'
  has_many :scratchpads
  has_many :warnings

  has_many :created_nodes, :class_name => 'Node', :foreign_key => 'created_by', :conditions => ['collection_id = ?', :current_collection]
  has_many :created_sources, :class_name => 'Source', :foreign_key => 'created_by', :conditions => ['collection_id = ?', :current_collection]
  has_many :created_bundles, :class_name => 'Bundle', :foreign_key => 'created_by', :conditions => ['collection_id = ?', :current_collection]
  has_many :created_blogentries, :class_name => 'Blogentry', :foreign_key => 'created_by', :conditions => ['collection_id = ?', :current_collection]
  has_many :created_forums, :class_name => 'Forum', :foreign_key => 'created_by', :conditions => ['collection_id = ?', :current_collection]
  has_many :created_topics, :class_name => 'Topic', :foreign_key => 'created_by', :conditions => ['collection_id = ?', :current_collection]
  has_many :created_posts, :class_name => 'Post', :foreign_key => 'created_by', :conditions => ['collection_id = ?', :current_collection]

  validates_presence_of     :firstname, :lastname
  validates_presence_of     :login,                      :if => :login_required?
  validates_presence_of     :password,                   :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false

  file_column :image, :magick => { 
    :versions => { 
      "thumb" => "56x56!", 
      "slide" => "135x135!", 
      "preview" => "750x540>" 
    }
  }

  before_create :make_activation_code
  before_save :encrypt_password

  # spoke custom methods
  
  def find_or_create_scratchpads
    if (self.scratchpads.size == 0)
      (1..4).each do |i|
        self.scratchpads << Scratchpad.new( :user => @thisuser, :name => "pad#{i}" )
      end
    end
    self.scratchpads
  end

  def can_login?
    !status.nil? and status > 0 and !login.nil? and login != '' and !email.nil?
  end

  def editor?
    status >= 100
  end

  def admin?
    status >= 200
  end
  
  def is_developer?
    status >= 300
  end
  
  # rest is standard acts_as_authenticated
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]
    u && u.authenticated?(password) ? u : nil
  end

  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    self.save!
  end

  def recently_activated?
    @activated
  end

  def activated?
    activated_at != nil
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
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def name
    return firstname + ' ' + lastname
  end
  
  def best_name
    diminutive.nil? ? name : diminutive
  end
  
  public
  
    def self.currently_online
      User.find(:all, :conditions => ["last_seen_at > ?", Time.now.utc-5.minutes])
    end
  
  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      !login.blank? && (crypted_password.blank? || !password.blank?)
    end

    def login_required?
      !password.blank? || !crypted_password.blank?
    end
    
    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
end
