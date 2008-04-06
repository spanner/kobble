class Tag < ActiveRecord::Base

  belongs_to :account
  has_many :taggings
  has_many_polymorphs :taggables, :from => Spoke::Config.content_models(:except => :tags), :through => :taggings
  acts_as_spoke :except => [:discussion, :collection]
  acts_as_catcher :taggables, {:tag => :subsume}

  def self.sort_options 
    {
      'name' => 'name',
      'date' => 'created_at',
      'popularity' => 'popularity',     # special case
    }
  end
  
  def stem
    name.split.map{|w| w.stem}.join('_')
  end
  
  def subsume(subsumed)
    self.taggables += subsumed.taggables
    self.flags += subsumed.flags
    self.children += subsumed.children
    self.description = subsumed.description if self.description.nil? or self.description.size == 0
    self.body = subsumed.body if self.body.nil? or self.body.size == 0
    self.image = subsumed.image if self.image.nil? or self.image.size == 0
    self.clip = subsumed.clip if self.clip.nil? or self.clip.size == 0
    subsumed.delete
  end
    
  def self.from_list(taglist)
    taglist.split(/[,;]\s*/).uniq.map { |t| Tag.find_or_create_by_name(t) }
  end

end

