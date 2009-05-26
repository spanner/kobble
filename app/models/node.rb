class Node < ActiveRecord::Base

  is_material

  belongs_to :source
  belongs_to :collection

  validates_presence_of :name, :description, :collection
  validate :must_have_body_clip_or_file

  def self.nice_title
    "fragment"
  end

  def clipped
    clipfile = read_attribute(:clip)
    unless (clipfile)
      if (self.source && self.source.clip) then
        sourcefile = self.source.clip
        if (self.playfrom || self.playto) then
          logger.warn("#{RAILS_ROOT}/audiocutter/mp3cut -file #{sourcefile} -in #{self.playfrom} -out #{self.playto}")
          clipfile = File.basename(`#{RAILS_ROOT}/audiocutter/mp3cut -file #{sourcefile} -in #{self.playfrom} -out #{self.playto}`);
          write_attribute(:clip, clipfile)
        else
          clipfile = sourcefile
        end
      end
      "/#{self.source.clip_options[:base_url]}/#{self.source.clip_relative_dir}/#{clipfile}"
    end
  end
  
  def has_clip?
    return false if self.clip.nil? && self.source.clip.nil?
    return false if self.playfrom_seconds == self.playto_seconds
    return true
  end
  
  def duration
    if (self.clip || self.source && self.source.clip)
      read_attribute(:playto) - read_attribute(:playfrom)
    else
      0
    end
  end
  
  def playfrom=(timecode)
    write_attribute(:playfrom, to_seconds(timecode))
  end
  
  def playto=(timecode)
    write_attribute(:playto, to_seconds(timecode))
  end

  def playfrom
    to_timecode(read_attribute(:playfrom))
  end
  
  def playto
    to_timecode(read_attribute(:playto))
  end
  
  def playfrom_seconds
    read_attribute(:playfrom)
  end

  def playto_seconds
    read_attribute(:playto)
  end

  def catch_this(object)
    case object.class.to_s
    when 'Tag'
      return object.catch_this(self)
    when 'Flag'
      return object.catch_this(self)
    else
      return CatchResponse.new("don't know what to do with a #{object.nice_title}", '', 'failure')
    end
  end

  private
  
  def to_seconds (timecode)
    return 0 unless timecode
    return timecode if timecode !~ /[^\d\.]/
    fragments = timecode.split(/:/)

    case fragments.length
    when 1 # seconds
      s = fragments[0]
    when 2 # mm:ss 
      m = fragments[0]
      s = fragments[1]
    when 3 # hh:mm:ss
      h = fragments[0]
      m = fragments[1]
      s = fragments[2]
    when 4  # hh:mm:ss:ff, where ff is frames at 30fps
      h = fragments[0]
      m = fragments[1]
      s = fragments[2]
      s += fragments[3]/30 if fragments[3]
    end
    ss = s.to_f
    ss += (m.to_i * 60) if m;
    ss += (h.to_i * 3600) if h;
    ss
  end
  
  def to_timecode (s)
    return '00:00:00:00' unless s
    h = (s/3600).floor;
    m = ((s % 3600)/60).floor;
    s = s % 60;
    sprintf("%02d:%02d:%02d:00", h, m, s)
  end

  def must_have_body_clip_or_file
    if body.blank? and clip.blank? and file.blank?
      errors.add(:body, "source must have at least one of body, clip or file") 
      errors.add(:clip, "source must have at least one of body, clip or file") 
      errors.add(:file, "source must have at least one of body, clip or file") 
    end
  end
    
end
