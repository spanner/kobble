class CollectedController < ActionController::Base

  before_filter :get_collection
  before_filter :get_item, :only => [:show, :edit, :update, :destroy]
  before_filter :get_deleted_item, :only => [:recover, :eliminate]
  before_filter :get_items, :only => [:index]
  after_filter :update_index, :only => [:create, :update, :destroy, :describe]
   
  def index
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
    @thing = current_collection.send(association).build(params[parameter_head])
    @thing.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
  end

  def create
    @thing = current_collection.send(association).build(params[parameter_head])
    if @thing.save
      @thing.tags << Tag.from_list(params[:tag_list])
      flash[:notice] = "#{model_class} was successfully created."
      redirect_to url_for(@thing)
    else
      render :action => 'new'
    end
  end
  
  def edit
    
  end
  
  def update
    if @thing.update_attributes(params[parameter_head])
      @thing.taggings.clear
      @thing.tags << Tag.from_list(params[:tag_list])
      flash[:notice] = "#{model_class} was successfully updated."
      redirect_to url_for(@thing)
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
  
  # do uncollected controllers need to implement catch?
  # eg. collections.

  def catch
    @caught = params[:caughtClass].to_s._as_class.find( params[:caughtID] )
    @response = @thing.catch_this(@caught) if @thing and @caught
    render_thing_or_response
  rescue => e
    flash[:error] = e.message
    @response = Material::CatchResponse.new(e.message, '', 'failure')
    render_thing_or_response
  end
    
  def drop
    @dropped = params[:droppedClass]._as_class.find(params[:droppedID])
    @response = @thing.drop_this(@dropped) if @thing and @dropped
    render_thing_or_response
  rescue => e
    flash[:error] = e.message
    @response = Material::CatchResponse.new(e.message, '', 'failure')
    render_thing_or_response
  end
  
  
  
  
  
  protected
    def working_on
      request.parameters[:controller].to_s
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

    def get_collection
      current_collection = current_account.collections.find(params[:collection_id])
    end
    
    def get_item
      @thing = current_collection.send(association).find(params[:id])
    end
    
    def get_deleted_item
      @thing = model_class.find_only_deleted( params[:id] )
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
