class CollectionsController < AccountScopedController
  
  before_filter :require_account_admin, :except => [:index, :show]

  def index
    @list = current_user.collections_available
  end

  def show

  end

  def new
    @thing = current_account.collections.build
    respond_to do |format| 
      format.html
      format.json { render :json => @thing.to_json }
      format.js { render :layout => false }
    end
  end
  
  def create
    @thing = current_account.collections.build(params[:collection])
    @thing.last_active_at = Time.now
    @thing.abbreviation = @thing.name.initials_or_beginning if @thing.abbreviation.nil? || @thing.abbreviation == ""  #defined in spoke_content plugin's StringExtensions
    if @thing.save
      current_user.permission_for(@thing).activate
      current_user.activation_of(@thing).activate
      flash[:notice] = 'Collection was created.'
      respond_to do |format| 
        format.html { redirect_to url_for(@thing) }
        format.json { render :json => @thing.to_json }
        format.js { render :layout => false }
      end
    else
      render :action => 'new'
    end
  end

  def edit
    respond_to do |format| 
      format.html
      format.json { render :json => @thing.to_json }
      format.js { render :layout => false }
    end
  end

  def update
    if @thing.update_attributes(params[:thing])
      flash[:notice] = 'Collection was updated.'
      respond_to do |format| 
        format.html { redirect_to :action => 'show' }
        format.json { render :json => @thing.to_json }
        format.js { render :layout => false }
      end
    else
      render :action => 'edit'
    end
  end

  def predelete
    @other_collections = current_account.collections.select{|c| c != @thing}
  end
  
protected
  
  def current_collection
    return @current_collection if defined?(@current_collection)
    Collection.current = @current_collection = Collection.find_by_id(params[:collection_id] || params[:id])
  end
  
end
