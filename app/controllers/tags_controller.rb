class TagsController < ApplicationController

  def index
    cloud
    render :action => 'cloud'
  end

  def tree
    @list = Tag.find(:all, 
      :select => "tags.*, count(taggings.id) as use_count",
      :joins => "LEFT JOIN taggings on taggings.tag_id = tags.id",
      :conditions => ["tags.collection_id = ?", current_collection],
      :group => "taggings.tag_id",
      :order => @sort
    )
    @shoots = @list.select{|tag| tag.parent.nil?}
    @roots = @shoots.select{|tag| tag.children.count > 0}
  end
  
  def treemap
    @tags = Tag.find(:all, :include => 'nodes')
    @tagtree = {}
    @tags.each do |t|
      if (t.nodes.length && (t.id == 1 || ! t.parent_id.nil?) ) then
        @tagtree[ t.id ] = {
          :label => t.name,
          :parent => t.parent_id,
          :color => t.colour,
          :size => t.marked.length,
        }
      end
    end
  end
  
  def taglist
    @tags = Tag.find(:all, :include => :parent)
    @kwtree = @tags.collect{ |kw| kw.parentage }
    @kwtree.sort!
    render :layout => false
  end
  
  def matching
    @tags = Tag.find(:all, :conditions => "name like '%#{params[:stem]}%' and collection_id = #{Collection.current_collection.id}").collect {|t| "'#{t.name}'"}
    render :layout => false
  end
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  
  def cloud
    @list = Tag.find(:all, 
      :select => "tags.*, count(taggings.id) as use_count",
      :joins => "LEFT JOIN taggings on taggings.tag_id = tags.id",
      :conditions => ["tags.collection_id = ?", current_collection],
      :group => "taggings.tag_id",
      :order => 'name'
    )
  end
  
  def show
    @tag = Tag.find(params[:id])
  end

  def new
    @tag = Tag.new
    @tags = Tag.find(:all, :include => :parent)
    @kwtree = @tags.collect{ |kw| kw.parentage }
    @kwtree.sort!
  end

  def create
    @tag = Tag.new(params[:tag])
    parentage = params[:parentage].split(':')
    @tag.name = parentage.pop
    if (parentage.nitems > 1)
      @tag.parent = Tag.find(:first, 
                             :select => "kw.*",
                             :conditions => ["kw.name = :parent and kwp.name = :grandparent", {:parent => parentage.pop, :grandparent => parentage.pop}],
                             :joins => "as kw inner join tags as kwp on kw.parent_id = kwp.id")
    elsif (parentage.nitems)
      @tag.parent = Tag.find(:first, 
                             :conditions => ["name = :parent and parent_id is NULL", {:parent => parentage.pop}])
    end
    if @tag.save
      flash[:notice] = 'Tag was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @tag = Tag.find(params[:id])
    @tags = Tag.find(:all, :include => :parent)
    @tagtree = @tags.collect{ |t| t.parentage }
    @tagtree.sort!
  end

  def update
    @tag = Tag.find(params[:id])
    parentage = params[:parentage].split('/')
    @tag.name = parentage.pop
    if (parentage && parentage.length)
      @tag.parent = Tag.find(:first, :conditions => [ "name = ?", parentage.pop])
    end
    if @tag.update_attributes(params[:tag])
      flash[:notice] = 'Tag was successfully updated.'
      redirect_to :action => 'show', :id => @tag
    else
      render :action => 'edit'
    end
  end
  
  def subsume
    @tag = Tag.find(params[:id])
    @subsumed = Tag.find(params[:subsume])
    @tag.subsume(@subsumed)
    respond_to do |format|
      format.html { redirect_to :action => 'show', :id => @tag }
      format.js { render :nothing => true }
      format.xml { head 200 }
    end
  end
  
  def consolidate
    tags = Tag.find(:all)
    seen = {}
    @removed = {}
    tags.each do |tag|
      if seen[tag.stem] 
        seen[tag.stem].subsume(tag)
        @removed[tag.name] = seen[tag.stem]
      else 
        seen[tag.stem] = tag
      end
    end
    cloud
    render :action => 'cloud'
  end
  
  def destroy
    Tag.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
