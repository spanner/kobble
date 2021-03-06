class Node < ActiveRecord::Base

  is_material
  belongs_to :source

  validates_presence_of :name, :collection
  validate :must_have_body_or_file

  def self.nice_title
    "fragment"
  end

  def clip_url
    if self.file_from == 'source'
      if self.has_in_or_out
        if (self.source && self.source.file_exists?) then
          sourcefile = source.file.path
          if (self.playfrom || self.playto) then
            STDERR.puts("#{RAILS_ROOT}/audiocutter/mp3cut -file #{sourcefile} -in #{self.playfrom_seconds} -out #{self.playto_seconds}")
            clipfile = `#{RAILS_ROOT}/audiocutter/mp3cut -file #{sourcefile} -in #{self.playfrom_seconds} -out #{self.playto_seconds}`;      # cutter only cuts if target file missing or out of date, and returns the file name with path
          else
            clipfile = sourcefile
          end
        end
        #! got to do this properly at some point
        "/sources/files/#{source.id}/#{File.basename(clipfile)}"
      else
        nil
      end
    else
      self.file.url
    end
  end
  
  # nodes can have files
  # or they can make reference to their source files
  # with audio and video and perhaps pdf excerpts
  
  def has_in_or_out
    (self.playfrom && self.playfrom_seconds.to_i > 0) || (self.playto && self.playto_seconds.to_i > 0) && self.playfrom_seconds != self.playto_seconds
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

  def must_have_body_or_file
    if body.blank? and file.blank?
      errors.add(:body, "fragment must have at least one of body or file") 
      errors.add(:file, "fragment must have at least one of body or file") 
    end
  end
    
end
