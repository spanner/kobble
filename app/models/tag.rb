class Tag < ActiveRecord::Base
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :collection
  acts_as_tree :order => 'name'
  # attr_accessor :use_count

  has_many_polymorphs :marks, :skip_duplicates => true, :from => [:nodes, :sources, :bundles, :users, :questions, :blogentries, :topics]
  file_column :image, :magick => { 
    :versions => { 
      "thumb" => "56x56!", 
      "slide" => "135x135!", 
      "preview" => "750x540>" 
    }
  }
  
  def parentage
    return self.name unless self.parent
    return self.parent.parentage + ': ' + self.name
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

  def has_description?
    !self.description.nil? and self.description.length != 0
  end

  def has_image?
    !self.image.nil?# and File.file? self.image
  end

  def has_clip?
    !self.clip.nil?# and File.file? self.clip
  end

  def has_marks?
    self.marks.count > 0
  end

end

