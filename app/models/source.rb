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
