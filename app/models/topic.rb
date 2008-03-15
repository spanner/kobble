class Topic < ActiveRecord::Base

  acts_as_spoke :except => [:illustration, :discussion, :index]

  belongs_to :speaker, :class_name => 'User', :foreign_key => 'speaker_id'
  has_many :monitorships, :dependent => :destroy
  has_many :monitors, :through => :monitorships, :conditions => ['monitorships.active = ?', true], :source => :user, :order => 'users.login'
  has_many :memberships, :as => :member, :dependent => :destroy
  has_many :bundles, :through => :memberships
  has_many :scratches, :as => :scrap, :dependent => :destroy
  has_many :scratchpads, :through => :scratches
  
  has_many :posts, :order => 'posts.created_at', :dependent => :destroy do
    def last
      @last_post ||= find(:first, :order => 'posts.created_at desc')
    end
  end

  belongs_to :replied_by_user, :foreign_key => "replied_by", :class_name => "User"
  belongs_to :subject, :polymorphic => true
  
  validates_presence_of :title, :subject
  
  before_create :set_default_replied_at_and_sticky

  attr_accessible :title
  attr_accessor :body

  def name
    title
  end
  
  def voice_count
    posts.count(:select => "DISTINCT created_by")
  end
  
  def voices
    # TODO - optimize
    posts.map { |p| p.creator }.uniq
  end
  
  def hit!
    self.class.increment_counter :hits, id
  end

  def sticky?() sticky == 1 end

  def views() hits end

  def paged?() posts_count > 25 end
  
  def last_page
    (posts_count.to_f / 25.0).ceil.to_i
  end
  
  def subject_path  
    { 
      :controller => subject.class.to_s.underscore.pluralize, 
      :action => 'show', 
      :id => subject
    }
  end
  
  protected
    def set_default_replied_at_and_sticky
      self.replied_at = Time.now.utc
      self.sticky   ||= 0
    end

    def self.index_fields
      STDERR.puts "%%% Topic.index_fields"
      ['name']
    end

    def self.index_concatenation
      STDERR.puts "%%% Topic.index_concatenation"
      [
        {:association_name => 'posts', :field => 'body', :as => 'posts'}
      ]
    end

end
