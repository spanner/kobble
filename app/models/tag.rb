class Tag < ActiveRecord::Base

  attr_accessor :used
  is_material :except => [:description, :organisation]
  has_many :taggings, :dependent => :destroy

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
    
  def self.from_list(taglist, collection=Collection.current)
    taglist.split(/[,;]\s*/).uniq.map { |name| Tag.find_or_create_by_name_and_collection_id(name.downcase, collection.id) }
  end

  def tagged
    taggings.map{|t| t.taggable }
  end
  
  def self.all_with_popularity(account)
    tags = self.in_account(account).with_popularity
    tags.each {|t| t.used = t.use_count }
    tags
  end
  
  def self.create_accessors_for(klass)
    Tagging.send(:named_scope, "of_#{klass.to_s.downcase.pluralize}".intern, :conditions => { :taggable_type => klass.to_s })
    define_method("#{klass.to_s.downcase}_taggings") { self.taggings.send("of_#{klass.to_s.downcase.pluralize}".intern) }
    define_method("#{klass.to_s.downcase.pluralize}") { self.send("#{klass.to_s.to_s.downcase}_taggings".intern).map{|l| l.member}.uniq }
  end
  
end

