class TagsController < CollectionScopedController

  def index
    taggings = Tagging.in_collection(current_collection).grouped_with_popularity
    taggings.each {|t| t.tag.used = t.use_count }
    @list = taggings.map {|t| t.tag }.uniq.sort{|a,b| a.name <=> b.name}
  end

  def matching
    @tags = Tag.in_collection(current_collection).matching(params[:stem])
    @tagnames = @tags.map{|t| t.name}.uniq
    respond_to do |format|
      format.json { render :json => @tagnames.to_json }
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
    
end
