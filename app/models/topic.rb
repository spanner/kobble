class Topic < ActiveRecord::Base

  # topics are just linking records: they connect a number of posts to an object
  # and hold administrative information like the latest poster and the initiator of the conversation

  acts_as_spoke :except => [:illustration, :discussion, :index]
  acts_as_catcher :tags, :flags

  belongs_to :referent, :polymorphic => true

  has_many :monitorships, :dependent => :destroy
  has_many :monitors, :through => :monitorships, :conditions => ['monitorships.active = ?', true], :source => :user

  has_many :posts, :order => 'posts.created_at', :dependent => :destroy

  validates_presence_of :name, :referent
  before_create :set_default_replied_at
  
  def add_monitors(users)
    users = [users] unless users.is_a?(Array)
    users.each do |user|
      m = self.monitorships.create({ 
        :user => user,
        :active => true
      })
    end
  end
  
  
  def self.nice_title
    "conversation"
  end
  
  protected
    def set_default_replied_at
      self.replied_at = Time.now.utc
    end

end
