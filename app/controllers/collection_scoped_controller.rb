class CollectionScopedController < AccountScopedController

  # this is the main resource controller and defined most activities
  # model-specific controllers only deviate from this template to offer
  # specific functional paths
  
  helper_method :current_collection
  before_filter :require_collection
  
  before_filter :get_working_class
  before_filter :get_item, :only => [:show, :edit, :update, :destroy]
  before_filter :get_deleted_item, :only => [:recover, :eliminate]
  before_filter :get_items, :only => [:index]
  after_filter :update_index, :only => [:create, :update, :destroy, :describe]
   
  def index
    @klass = 
    respond_to do |format|
      format.html { render :template => 'shared/list' }
      format.js { render :template => 'shared/list', :layout => 'inline' }
    end
  end

  def show
  rescue ActiveRecord::RecordNotFound
    @thing = model_class.find_only_deleted(params[:id])
    render :template => 'shared/deleted'
  end
    
  def new
    @thing = current_collection.send(association).build(params[:thing])
    @thing.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
  end

  def create
    @thing = current_collection.send(association).build(params[:thing])
    if @thing.save
      @thing.tags << Tag.from_list(params[:tag_list])
      flash[:notice] = "#{model_class} was successfully created."
      redirect_to collected_url_for(@thing)
    else
      render :action => 'new'
    end
  end
  
  def edit
    
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
    
  def destroy
    @thing.reassign_to = model_class.find(params[:reassign_to]) if params[:reassign_to] && @thing.respond_to?('reassign_to')
    @thing.class.transaction { @thing.destroy }
    flash[:notice] = "#{@deleted.name} has been deleted"
    @response = Material::CatchResponse.new("#{@thing.name} deleted", 'delete')
    render_thing_or_response
  rescue => e
    flash[:error] = e.message
    @response = Material::CatchResponse.new(e.message, '', 'failure')
    render_thing_or_response
  end

  def recover
    @thing.recover!
    flash[:notice] = "#{@recovered.name} recovered"
    respond_to do |format|
      format.html { redirect_to url_for(@thing) }
      format.json { render :json => @thing.to_json }
    end
  end
  
  def eliminate
    model_class.transaction {
      @thing.logged_events.each { |e| e.destroy }
      @thing.destroy_without_callbacks!
    }
    respond_to do |format|
      format.html { render :template => 'shared/eliminated' }
      format.json { render :json => @thing.to_json }
    end
  end
    
  
protected
  
  def current_collection
    return @current_collection if defined?(@current_collection)
    @current_collection = Collection.find_by_id(params[:collection_id])
  end
  
  def require_collection
    if current_collection
      Collection.current = current_collection
    else
      store_location
      flash[:notice] = "Please choose a collection"
      redirect_to root_url
      return false
    end
  end
  
  def get_working_class
    @klass = model_class
  end
  
  def get_item
    @thing = current_collection.send(association).find(params[:id])
  end
  
  def get_deleted_item
    @thing = model_class.find_only_deleted(params[:id])
  end
  
  def get_items
    @list = current_collection.send(association).paginate(paging)
  end
  
  def paging
    {
      :page => params[:page] || 1,
      :per_page => params[:per_page] || 100,
    }
  end

  def working_on
    request.parameters[:controller].singularize.to_s
  end

  def model_class
    working_on.as_class
  end

  def association
    working_on.downcase.pluralize.intern
  end

  def parameter_head
    working_on.downcase.intern
  end

  def render_thing_or_response
    respond_to do |format|
      format.html { redirect_to url_for(@thing) }
      format.json { render :json => @response.to_json }
    end
  end

private

  def update_index
    if ActsAsXapian::ActsAsXapianJob.count > 0
      spawn(:nice => 7) do
        %x(rake xapian:update_index) 
      end
    end
  end

end
