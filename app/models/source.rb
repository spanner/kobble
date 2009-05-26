class Source < ActiveRecord::Base

  is_material

  belongs_to :occasion
  has_many :nodes, :dependent => :destroy

  validates_presence_of :name, :description, :collection
  validate :must_have_body_clip_or_file

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
