class Tag < ActiveRecord::Base

  attr_accessor :used
  is_material :except => [:index, :description]
  belongs_to :account
  has_many :taggings, :dependent => :destroy
  can_catch :tags # in addition to all the catches set up by is_material in other classes

  named_scope :with_popularity, {
    :select => "tags.*, count(taggings.id) as use_count", 
    :joins => "INNER JOIN taggings on taggings.tag_id = tags.id", 
    :group => "taggings.tag_id", 
    :order => 'name ASC'
  }
  named_scope :in_account, lambda { |account| {
    :conditions => { :account_id => account.id }} 
  }
  named_scope :matching, lambda { |stem| {
    :conditions => "name like '#{stem}%'"} 
  }
    
  def subsume(subsumed)
    self.taggings += subsumed.taggings
    self.notes += subsumed.annotations
    self.description = subsumed.description if self.description.nil? or self.description.size == 0
    self.body = subsumed.body if self.body.nil? or self.body.size == 0
    self.image = subsumed.image if self.image.nil? or self.image.size == 0
    self.clip = subsumed.clip if self.clip.nil? or self.clip.size == 0
    subsumed.destroy
    Material::CatchResponse.new("#{subsumed.name} merged into #{self.name}", "delete")
  end
    
  def self.from_list(taglist, collection=Collection.current)
    taglist.split(/[,;]\s*/).uniq.map { |name| Tag.find_or_create_by_name_and_collection_id(name.downcase, collection.id) }
  end

  def tagged
    taggings.map{|t| t.taggable }
  end
  
  def catch_this(object)
    case object.class.to_s
    when 'Tag'
      subsume(object)
      return Material::CatchResponse.new("#{object.name} subsumed into #{self.name}", 'delete', 'success')
    else
      if self.taggings.of(object).empty?
        self.taggings.create!(:taggable => object)
        return Material::CatchResponse.new("#{object.name} tagged with #{self.name}", 'copy', 'success')
      else
        return Material::CatchResponse.new("#{self.name} already attached to #{object.name}", '', 'failure')
      end
    end
  end

  def drop_this(object)
    self.taggings.delete(self.taggings.of(object))
    return Material::CatchResponse.new("#{self.name} tag removed from #{object.name}", 'delete', 'success')
  end
  
  def self.all_with_popularity(account)
    tags = self.in_account(account).with_popularity
    tags.each {|t| t.used = t.use_count }
    tags
  end
  
end

