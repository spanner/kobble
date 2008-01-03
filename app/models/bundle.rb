class Bundle < ActiveRecord::Base

  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :collection

  has_many :topics, :as => :subject
  has_many :members, :as => :superbundle, :from => [:nodes, :sources, :bundles, :questions, :users, :blogentries, :posts, :topics]
  
  # all dropped items are eaten unless already contained
  # set merging must be explicitly commanded
  
  acts_as_catcher :members, :tags, :flags
 
  file_column :image, :magick => { 
    :versions => { 
      "thumb" => "56x56!", 
      "slide" => "135x135!", 
      "preview" => "750x540>" 
    }
  }

  public 
    
  # these will all move into a general purpose AR extension based on column type unless I find there is already a proper way to do it
  
  def tag_list
    tags.map {|t| t.name }.uniq.join(', ')
  end

  def has_members?
    self.members.count > 0
  end

  def has_notes?
    (observations.nil? || observations.size == 0) && (emotions.nil? || emotions.size == 0) && (arising.nil? || arising.size == 0) ? false : true
  end

  def has_synopsis?
    !self.synopsis.nil? and self.synopsis.length != 0
  end

  def has_body?
    !self.body.nil? and self.body.length != 0
  end

  def has_image?
    !self.image.nil?# and File.file? self.image
  end

  def has_clip?
    !self.clip.nil?# and File.file? self.clip
  end
    
  def has_topics?
    self.topics.count > 0
  end
  
  def has_tags?
    self.tags.count > 0
  end
  
  def tag_list
    self.tags.map {|t| t.name }.uniq.join(', ')
  end

end

