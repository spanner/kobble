class TagsController < ApplicationController

  #! add option to autocomplete only current collection tags

  def matching
    @tags = Tag.in_account(current_account).matching(params[:stem])
    @tagnames = @tags.map{|t| t.name}.uniq
    respond_to do |format|
      format.json { render :json => @tagnames.to_json }
    end
  end
  
  def cloud
    if params[:show] == 'all'
      @list = Tag.all_with_popularity(current_account)
    else
      taggings = Tagging.in_collection(current_collection).grouped_with_popularity
      taggings.each {|t| t.tag.used = t.use_count }
      @list = taggings.map {|t| t.tag }.uniq.sort{|a,b| a.name <=> b.name}
    end
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
    
  def destroy
    Tag.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
end
