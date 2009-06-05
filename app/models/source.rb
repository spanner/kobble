class Source < ActiveRecord::Base

  is_material
  belongs_to :occasion
  has_many :nodes, :dependent => :destroy

  validates_presence_of :name, :collection
  validate :must_have_body_or_file

  def uploaded_file=(upload)
    upload.content_type = MIME::Types.type_for(upload.original_filename).to_s
    self.file = upload
  end

  def self.nice_title
    "source"
  end
  
  def has_file?
    not self.file_file_name.blank?
  end

  def file_exists?
    self.has_file? and File.file? self.file.path
  end

  def file_extension
    self.has_file? ? self.file_file_name.split('.').last : nil
  end
  
  def is_audio?
    true if self.has_file? && self.file.content_type =~ /^audio/i
  end

  def is_video?
    true if self.has_file? && self.file.content_type =~ /^video/i
  end
  
  def is_audio_or_video?
    is_audio? or is_video?
  end

  def is_pdf?
    true if has_file? && file.content_type =~ /pdf/i
  end

  def is_doc?
    true if has_file? && file.content_type =~ /msword/i
  end

  def is_text?
    true unless has_file?
  end

  def file_type
    %w{audio video pdf doc text}.detect {|type| self.send("is_#{type}?".intern) }
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
  
  def must_have_body_or_file
    if body.blank? and file.nil?
      errors.add(:body, "source must have body text or file") 
      errors.add(:file, "source must have body text or file") 
    end
  end
  

end
