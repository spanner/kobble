require 'digest/sha1'

class Account < ActiveRecord::Base

  belongs_to :holder, :class_name => 'User', :foreign_key => 'user_id'
  has_many :collections
  before_create :find_or_create_holder



  
  def self.sort_options
    {
      "last name" => "lastname, firstname",
      "first name" => "firstname, lastname",
      "registration date" => "created_at",
    }
  end
  
  def self.default_sort
    "last name"
  end
  
  def self.nice_title
    "person"
  end

  def find_or_create_scratchpads
    if (self.created_scratchpads.empty?)
      (1..4).each do |i|
        self.created_scratchpads.create({:name => "pad#{i}"})
      end
    end
    self.created_scratchpads
  end

  def can_login?
    status > 0 and !login.nil? and login != '' and !email.nil?
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
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]
    return nil unless u && u.authenticated?(password)
    u.last_login = Time.now.utc
    u.save!
    u
  end

  def activate
    @activated = true
    self.status = 10
    self.last_login = self.activated_at = Time.now.utc
    self.activation_code = nil
    self.save!
  end

  def deactivate
    @activated = false
    self.status = 0
    self.save!
  end

  # did they activate in this request?
  def justnow_activated?
    @activated
  end

  # did they activate within the last five minutes?
  def recently_activated?
    return false unless activated?
    (Time.now - activated_at) <= 300
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
    self.diminutive.nil? ? self.name : self.diminutive
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
  
  public
  
    def self.everything_monitors
      []
    end
  
    def self.currently_online
      User.find(:all, :conditions => ["last_seen_at > ?", Time.now.utc-5.minutes])
    end
    
    def has_nodes?
      self.respond_to?('nodes') && self.nodes.count > 0
    end
    
    def has_sources?
      self.respond_to?('sources') && self.sources.count > 0
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

    def generate_password(length=8)
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("1".."9").to_a
      Array.new(length, '').collect{chars[rand(chars.size)]}.join
    end
end
