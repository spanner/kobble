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
      format.js { render :layout => 'inline' }
    end
  end

  def create
    if @thing.save
      @thing.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
      respond_to do |format|
        format.html { 
          flash[:notice] = "#{@thing.nice_title} created."
          redirect_to collected_url_for(@thing) 
        }
        format.js { render :layout => false }
      end
    else
      respond_to do |format|
        flash[:error] = "Problem saving #{@thing.nice_title}."
        format.html { render :action => 'new' }
        format.js { render :action => 'new', :layout => 'inline' }
      end
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
  rescue ActiveRecord::RecordNotFound
    request_collection
    get_deleted_item
    render :template => 'shared/deleted'
  end
  
  def get_deleted_item
    @thing = model_class.find_with_deleted(params[:id])
  end
  
  def get_items
    @list = current_collection.send(association).paginate(paging)
  end
  
  def build_item
    @thing = current_collection ? current_collection.send(association).build(params[:thing]) : model_class.new(params[:thing])
  end
  
  def thing_or_response
    respond_to do |format|
      format.html { redirect_to collected_url_for(@thing) }
      format.json { render :json => @response.to_json }
    end
  end

end
