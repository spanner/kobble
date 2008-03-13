class Account < ActiveRecord::Base

  belongs_to :user        # the account holder
  has_many :users         # the users added to this account by the account holder
  has_many :collections   # the collections added to this account by the account holder or a sufficiently privileged user
    
  def self.nice_title
    "account"
  end

end
