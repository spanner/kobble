class Node < ActiveRecord::Base

  acts_as_spoke

  belongs_to :question
  belongs_to :source
  belongs_to :collection

  # acts_as_catcher :tags, :flags, :speaker, :source

  file_column :file
  before_save FileCallbacks.new

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
    end
    "/#{self.source.clip_options[:base_url]}/#{self.source.clip_relative_dir}/#{clipfile}"
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
    read_attribute(:playfrom)
  end
  
  def playto
    read_attribute(:playto)
  end
  
  def has_flags?
    
  end
  
  def has_fatal_flags?
  
  end
  
  def find_some_text
    !synopsis.nil? && synopsis.length > 0 ? synopsis : body
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
  
  def filetype
    self.file ? self.file_relative_path.split('.').last : nil
  end
  
  # these will all move into a general purpose AR extension based on column type unless I find there is already a proper way to do it
  
  def has_notes?
    (observations.nil? || observations.size == 0) && (emotions.nil? || emotions.size == 0) && (arising.nil? || arising.size == 0) ? false : true
  end

  def has_origins?
    ! (self.question.nil? and self.source.nil? and self.creator.nil?)
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
