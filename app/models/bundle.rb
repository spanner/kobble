class Bundle < ActiveRecord::Base

  acts_as_spoke
  acts_as_illustrated

  acts_as_organised :except => :bundles

  has_many :bundlings, :dependent => :destroy
  has_many :bundleds, :through => :bundlings
  
  # acts_as_catcher :members
 
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

