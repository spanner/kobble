class Account < ActiveRecord::Base

  belongs_to :user
  has_many :users
  has_many :collections, :order => 'name'
  has_many :tags
  
  def self.nice_title
    "account"
  end

end
