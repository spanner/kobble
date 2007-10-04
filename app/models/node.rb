class Node < ActiveRecord::Base

  belongs_to :source
  belongs_to :user
  belongs_to :person
  belongs_to :collection

  has_and_belongs_to_many :people

  file_column :image, :magick => { 
    :versions => { 
      "thumb" => "56x56!", 
      "slide" => "135x135!", 
      "preview" => "750x540>" 
    },
    :store_dir => "ul"
  }
  
  def clip
    clipfile = read_attribute(:clip)
    unless (clipfile)
      if (self.source && self.source.clip) then
        sourcefile = self.source.clip
        if (self.playfrom || self.playto) then
          logger.debug("#{RAILS_ROOT}/audiocutter/mp3cut -file #{sourcefile} -in #{self.playfrom} -out #{self.playto}")
          clipfile = File.basename(`#{RAILS_ROOT}/audiocutter/mp3cut -file #{sourcefile} -in #{self.playfrom} -out #{self.playto}`);
          write_attribute(:clip, clipfile)
        else
          clipfile = sourcefile
        end
      end
    end
    "/#{self.source.clip_options[:base_url]}/#{self.source.clip_relative_dir}/#{clipfile}"
  end

  def clip=(path)
    write_attribute(:clip, path)
  end
  
  def duration
    if (self.source.clip)
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
#    to_timecode(read_attribute(:playfrom))
    read_attribute(:playfrom)
  end
  
  def playto
#    to_timecode(read_attribute(:playto))
    read_attribute(:playto)
  end
  
  def has_warnings
    
  end
  
  def has_fatal_warnings
  
  end
  
  private
  
  def to_seconds (timecode)
    return 0 unless timecode
    return timecode if timecode !~ /[^\d\.]/
    logger.info("to_seconds(#{timecode})")
    fragments = timecode.split(/:/)

    case fragments.length
    when 1 # mm:ss 
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
    logger.info("h = #{h}, m = #{m}, s= #{s}")
    ss = s.to_f
    ss += (m.to_i * 60) if m;
    ss += (h.to_i * 3600) if h;

    logger.info("final ss = #{ss}")

    ss
  end
  
  def to_timecode (s)
    return '00:00:00:00' unless s
    logger.info("to_timecode(#{s})")
    h = (s/3600).floor;
    logger.info("h = #{h}")
    m = ((s % 3600)/60).floor;
    logger.info("m = #{m}")
    s = s % 60;
    logger.info("s = #{s}")
    sprintf("%02d:%02d:%02d:00", h, m, s)
  end
  
  public
  
end