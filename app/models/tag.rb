class Tag < ActiveRecord::Base
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :collection
  acts_as_tree :order => 'name'

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
    query ="select t.id, t.name, count(tm.mark_id) as marks_count 
from tags as t, marks_tags as tm 
where tm.tag_id = t.id and t.collection_id = #{Collection.current_collection.id} 
group by tm.tag_id order by name"
    Tag.find_by_sql(query);
  end

end

