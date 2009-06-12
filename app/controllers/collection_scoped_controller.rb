class CollectionScopedController < AccountScopedController

  # this is the main resource controller and defined most activities
  # model-specific controllers only deviate from this template to offer
  # specific functional paths
  
  helper_method :current_collection
  before_filter :require_collection

  # everything that inherits from here is tagged

  def new
    @thing.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def create
    if @thing.save
      @thing.tags << Tag.from_list(params[:tag_list])
      flash[:notice] = "#{model_class} was successfully created."
      redirect_to collected_url_for(@thing)
    else
      render :action => 'new'
    end
  end
    
  def update
    if @thing.update_attributes(params[:thing])
      unless @thing.tag_list == params[:tag_list]
        @thing.taggings.clear
        @thing.tags << Tag.from_list(params[:tag_list])
      end
      flash[:notice] = "#{model_class} was successfully updated."
      redirect_to collected_url_for(@thing)
    else
      flash[:notice] = 'failed to update.'
      render :action => 'edit'
    end
  end
  
protected
  
  def get_item
    @thing = current_collection.send(association).find(params[:id])
  end
  
  def get_deleted_item
    @thing = current_collection.send(association).find_only_deleted(params[:id])
  end
  
  def get_items
    @list = current_collection.send(association).paginate(paging)
  end
  
  def thing_or_response
    respond_to do |format|
      format.html { redirect_to collected_url_for(@thing) }
      format.json { render :json => @response.to_json }
    end
  end

end
