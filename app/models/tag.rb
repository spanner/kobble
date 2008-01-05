class Tag < ActiveRecord::Base
  acts_as_spoke
  has_many_polymorphs :taggables, :from => self.organised_classes(:except => :tags), :through => :taggings
  acts_as_tree :order => 'name'

  def subsume(subsumed)
    self.marks << subsumed.marks
    self.flags << subsumed.flags
    self.children << subsumed.children
    self.description = subsumed.description if self.description.nil? or self.description.size == 0
    self.image = subsumed.image if self.image.nil? or self.image.size == 0
    subsumed.destroy
  end
  
  def parentage
    return self unless self.parent
    return [self.parent.parentage, self]
  end
  
  def ancestry
    return unless self.parent
    return self.parent.parentage
  end  

  def self.find_or_create_branch(branch)
    name = branch.pop
    tag = (branch.nitems > 0) ?
      Tag.find(:first,
        :conditions => ["tags.name= ? AND tp.name = ?", name, branch[-1]], 
        :select => "tags.*", 
        :joins => "as tags inner join tags as tp on tags.parent_id = tp.id",
        :order => "tags.name") :
      Tag.find(:first,
        :conditions => ["name= ? AND parent_id IS NULL", name]);

    unless (tag)
      if (branch.nitems > 0)
        parent = Tag.find_or_create_branch(branch)
        tag = Tag.new(:name => name, :parent => parent)
      else
        tag = Tag.new(:name => name)
      end
      tag.save
    end
    return tag
  end

  def self.tags_with_popularity
    Tag.find(:all, 
      :select => "tags.*, count(marks_tags.id) as use_count",
      :joins => "LEFT JOIN marks_tags on marks_tags.tag_id = tags.id",
      :conditions => ["tags.parent_id = ?", self.id],
      :group => "marks_tags.tag_id",
      :order => 'use_count DESC'
    )
  end

  def children_with_count
    Tag.find(:all, 
      :select => "tags.*, count(marks_tags.id) as use_count",
      :joins => "LEFT JOIN marks_tags on marks_tags.tag_id = tags.id",
      :conditions => ["tags.parent_id = ?", self.id],
      :group => "marks_tags.tag_id",
      :order => 'name ASC'
    )
  end

end

