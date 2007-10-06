class Tag < ActiveRecord::Base
  belongs_to :user
  has_many_polymorphs :marks, :from => [:nodes, :sources, :bundles, :users]
  acts_as_tree :order => 'name', :counter_cache => true
  
  public

  def parentage
    return self.name unless self.parent
    return self.parent.parentage + '/ ' + self.name
  end
  
  def ancestry
    return unless self.parent
    return self.parent.parentage
  end  
  
  def nice (field)
    return unless self.respond_to?(field);
    textile = self.send(field)
    r = RedCloth.new textile
    return r.to_html;
  end

  def Tag.find_or_create_branch(branch)
    name = branch.pop
 
    tag = (branch.nitems > 0) ?
      Tag.find(:first,
        :conditions => ["tags.name= ? AND tagp.name = ?", name, branch[-1]], 
        :select => "tags.*", 
        :joins => "as tags inner join tags as tagp on tags.parent_id = tagp.id",
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

end

