class PermissionsController < AccountScopedController

  before_filter :require_account_admin
  skip_before_filter :get_item
  before_filter :get_permission, :except => [:index]

  def index
    @list = @user.all_permissions
    respond_to do |format| 
      format.html
      format.json { render :json => @list.to_json }
    end
  end

  def create
    activate
  end

  def destroy
    deactivate
  end

  def toggle
    if @thing && @thing.active?
      deactivate
    else 
      activate
    end
  end
  
  def activate
    @thing.update_attribute :active, true
    @message = "access to #{@thing.collection.name} granted to #{@thing.user.name}"
    flash[:notice] = @message
    respond_to do |format| 
      format.html { render :action => 'index' }
      format.json {
        render :json => { 
          :outcome => 'active',
          :message => @message 
        } 
      }
    end
  rescue => e
    flash[:error] = e.message
    respond_to do |format|
      format.html { render :action => 'index' }
      format.json { 
        render :json => {
          :outcome => 'failure',
          :message => e.message,
        }.to_json 
      }
    end
  end
  
  def deactivate
    @thing.update_attribute :active, false
    @message = "access to #{@thing.collection.name} withdrawn from #{@thing.user.name}"
    flash[:notice] = @message
    respond_to do |format| 
      format.html { render :action => 'index' }
      format.json {
        render :json => { 
          :outcome => 'inactive', 
          :message => @message 
        } 
      }
    end
  rescue => e
    flash[:error] = e.message
    respond_to do |format|
      format.html { render :action => 'index' }
      format.json { 
        render :json => {
          :outcome => 'failure',
          :message => e.message,
        }.to_json 
      }
    end
  end
  
protected
  
  def get_permission
    @user = User.find(params[:user_id]) if params[:user_id]
    @collection = Collection.find(params[:collection_id]) if params[:collection_id]
    unless params[:id] && @thing = Permission.find_by_id(params[:id])
      @thing = @user.permission_for(@collection) if @user && @collection
    end
    @thing
  end
  
end
