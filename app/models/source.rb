class Source < ActiveRecord::Base

  is_material
  belongs_to :occasion
  has_many :nodes, :dependent => :destroy

  validates_presence_of :name, :collection
  validate :must_have_body_clip_or_file

  def uploaded_file=(upload)
    
    logger.warn "!!! setting uploaded_file type"
    
    upload.content_type = MIME::Types.type_for(upload.original_filename).to_s
    
    logger.warn "    gives #{upload.content_type}"
    
    case upload.content_type
    when /^video/
      self.clip = upload
    when /^video/
      self.clip = upload
    when /^audio/
      self.clip = upload
    when /^image/
      self.image = upload
    else
      self.file = upload
    end
  end

  def self.nice_title
    "source"
  end

  def catch_this(object)
    case object.class.to_s
    when 'Tag'
      return object.catch_this(self)
    when 'Flag'
      return object.catch_this(self)
    else
      return Material::CatchResponse.new("don't know what to do with a #{object.nice_title}", '', 'failure')
    end
  end

  private 
  
  def must_have_body_clip_or_file
    if body.blank? and clip.blank? and file.blank?
      errors.add(:body, "source must have at least one of body, clip or file") 
      errors.add(:clip, "source must have at least one of body, clip or file") 
      errors.add(:file, "source must have at least one of body, clip or file") 
    end
  end
  

end
