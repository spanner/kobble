class TagsController < ApplicationController

  def views
    ['cloud', 'gallery']
  end

  def list_columns
    4
  end

  def list_length
    80
  end

  # tags always work across collections but within an account

  def limit_to_active_collections(klass=nil)
    limit_to_this_account(klass)
  end
  
  # this is a dirty dirty shortcut.
  # loading tags properly for this is very slow because of all the HMP preloaders
  # and since this is always an ajax call we need quick
  # so we just pull out the names directly

  def matching
    @tagnames = Tag.connection.select_values("SELECT name FROM #{Tag.table_name} where account_id = #{current_account.id} and name like '#{params[:stem]}%'").uniq
    respond_to do |format|
      format.html {  }
      format.json { 
        render :json => @tagnames.to_json
      }
    end
  end
  
  def cloud
    @list = Tag.find(:all, 
      :select => "tags.*, count(taggings.id) as use_count",
      :joins => "LEFT JOIN taggings on taggings.tag_id = tags.id",
      :conditions => limit_to_this_account,
      :group => "taggings.tag_id",
      :order => 'name'
    )
  end
  
  def show
    @tag = Tag.find(params[:id])
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(params[:tag])
    if @tag.save
      flash[:notice] = 'Tag was successfully created.'
      redirect_to :action => 'show', :id => @tag
    else
      render :action => 'new'
    end
  end

  def edit
    @tag = Tag.find(params[:id])
    @tags = Tag.find(:all, :conditions => limit_to_this_account)
  end

  def update
    @tag = Tag.find(params[:id])
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
      format.json { render :json => @tag.to_json }
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
    flas[:notice] = 'tags stemmed and consolidated'
    render :action => 'index'
  end
  
  def destroy
    Tag.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
end
