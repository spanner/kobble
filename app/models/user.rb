require 'digest/sha1'

class User < ActiveRecord::Base
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by' # some users can create other users
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :collection      # for editors and higher this is a changeable value that indicates foreground collection
  has_many :sources
  has_many :nodes
  has_many :bundles
  has_many :tags
  has_many :scratchpads
  has_many :warnings
end

class LoginUser < User
  attr_accessor :password

  file_column :image, :magick => { 
    :versions => { 
      "thumb" => "56x56!", 
      "slide" => "135x135!", 
      "preview" => "750x540>" 
    }
  }

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password

  # spoke custom methods
  
  def name
    return self.diminutive if self.diminutive
    return self.firstname + ' ' + self.lastname
  end
  
  def find_or_create_scratchpads
    if (self.scratchpads.size == 0)
      (1..4).each do |i|
        self.scratchpads << Scratchpad.new( :user => @thisuser, :name => "pad{i}" )
      end
    end
    self.scratchpads
  end

  def is_editor
    self.status >= 100
  end

  def is_admin?
    self.status >= 200
  end
  
  def is_developer?
    self.status >= 300
  end
  
  # rest is standard acts_as_authenticated
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
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

#  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
end
