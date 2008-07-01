class PermissionsController < ApplicationController

  # only accessible as nested resource of user
  
  before_filter :account_admin_required
  before_filter :find_or_create_permission

  def index
    @permissions = @user.all_permissions
    respond_to do |format| 
      format.html
      format.json { render :json => @permissions.to_json }
    end
  end

  def toggle
    @permission ||= Permission.find(params[:id])
    if @permission.active?
      deactivate
    else 
      activate
    end
  end
  
  def activate
    @permission ||= Permission.find(params[:id])
    @permission.update_attribute :active, true
    @message = "access granted to #{@permission.collection.name} for #{@permission.user.name}"
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
    @permission ||= Permission.find(params[:id])
    @permission.update_attribute :active, false
    @message = "access denied to #{@permission.collection.name} for #{@permission.user.name}"
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
  
  def create
    activate
  end
  
  def destroy
    deactivate
  end
  private
  
  def find_or_create_permission
    @permission = Permission.find(params[:id]) if params[:id]
    @user = User.find(params[:user_id]) if params[:user_id]
    @collection = Collection.find(params[:collection_id]) if params[:collection_id]
    @permission ||= @user.permission_for(@collection) if @user && @collection
    !@permission.nil?
  end
  
end
