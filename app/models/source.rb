class Source < ActiveRecord::Base

  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :speaker, :class_name => 'User', :foreign_key => 'speaker_id'
  belongs_to :collection
  belongs_to :occasion

  has_many :nodes, :dependent => :nullify
  has_many :topics, :as => :subject
  has_many :memberships, :as => :member, :dependent => :destroy
  has_many :bundles, :through => :memberships
  has_many :scratches, :as => :scrap, :dependent => :destroy
  has_many :scratchpads, :through => :scratches
  
  file_column :file
  file_column :clip
  file_column :image, :magick => { 
    :versions => { 
      "thumb" => "56x56!", 
      "slide" => "135x135!", 
      "preview" => "750x540>"
    }
  }
  
  before_save FileCallbacks.new
  # acts_as_catcher :tags, :flags, :nodes

  public 
  
  def filetype
    self.file ? self.file_relative_path.split('.').last : nil
  end
  
  # these will all move into a general purpose AR extension based on column type unless I find there is already a proper way to do it
  
  def has_notes?
    (observations.nil? || observations.size == 0) && (emotions.nil? || emotions.size == 0) && (arising.nil? || arising.size == 0) ? false : true
  end

  def has_circumstances?
    !self.circumstances.nil? and self.circumstances.length != 0
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
  
  def has_file?
    !self.file.nil?# and File.file? self.file
  end

  def has_extracted_text?
    !self.extracted_text.nil? and self.extracted_text.length != 0
  end
    
  def has_nodes?
    self.nodes.count > 0
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
