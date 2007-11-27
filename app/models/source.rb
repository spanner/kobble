class Source < ActiveRecord::Base

  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :speaker, :class_name => 'User', :foreign_key => 'speaker_id'
  belongs_to :collection
  belongs_to :occasion

  has_many :nodes                     # excerpted to
  has_many :topics, :as => :subject
  
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

  public 
  
  def filetype
    self.file ? self.file_relative_path.split('.').last : nil
  end
  
  def has_notes?
    (observations.nil? || observations.size == 0) && (emotions.nil? || emotions.size == 0) && (arising.nil? || arising.size == 0) ? false : true
  end

  def has_tags?
    false
  end
  
  def tag_list
    tags.map {|t| t.name }.uniq.join(', ')
  end
  
end
