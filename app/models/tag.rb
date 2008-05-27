class Tag < ActiveRecord::Base

  acts_as_spoke :except => [:collection, :index, :description, :annotation]
  belongs_to :account
  has_finder :in_account, lambda { |account| {:conditions => { :account_id => account.id }} }
  has_many :taggings, :dependent => :destroy
  can_catch :tags # in addition to all the catches set up by acts_as_spoke in other classes
  
  def stem
    name.split.map{|w| w.stem}.join('_')
  end
  
  def subsume(subsumed)
    self.taggings += subsumed.taggings
    self.flags += subsumed.flags
    self.description = subsumed.description if self.description.nil? or self.description.size == 0
    self.body = subsumed.body if self.body.nil? or self.body.size == 0
    self.image = subsumed.image if self.image.nil? or self.image.size == 0
    self.clip = subsumed.clip if self.clip.nil? or self.clip.size == 0
    self.emotions = subsumed.clip if self.emotions.nil? or self.emotions.size == 0
    self.arising = subsumed.clip if self.arising.nil? or self.arising.size == 0
    self.observations = subsumed.observations if self.observations.nil? or self.observations.size == 0
    subsumed.destroy
    CatchResponse.new("#{subsumed.name} merged into #{self.name}", "delete")
  end
    
  def self.from_list(taglist)
    taglist.split(/[,;]\s*/).uniq.map { |t| Tag.find_or_create_by_name(t) }
  end

  def tagged
    taggings.map{|t| t.taggable }
  end
  
  def catch_this(object)
    case object.class.to_s
    when 'Tag'
      subsume(object)
      return CatchResponse.new("#{object.name} subsumed into #{self.name}", 'delete', 'success')
    else
      if self.taggings.of(object).empty?
        self.taggings.create!(:taggable => object)
        return CatchResponse.new("#{object.name} tagged with #{self.name}", 'copy', 'success')
      else
        return CatchResponse.new("#{self.name} already attached to #{object.name}", '', 'failure')
      end
    end
  end

  def drop_this(object)
    self.taggings.delete(self.taggings.of(object))
    return CatchResponse.new("#{self.name} tag removed from #{object.name}", 'delete', 'success')
  end

end

