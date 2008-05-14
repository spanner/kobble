class PermissionsController < ApplicationController

  # only accessible as nested resource of user
  
  before_filter :account_admin_required
  before_filter :find_user

  def index
    @permissions = @user.all_permissions
    respond_to do |format| 
      format.html
      format.json { render :json => @permissions.to_json }
    end
  end

  def toggle
    @access = @user.permissions.find(params[:id])
    if @access.active?
      deactivate
    else 
      activate
    end
  end
  
  def activate
    @access = @user.permissions.find(params[:id])
    @collection = @access.collection
    @access.update_attribute :active, true
    @message = "access granted to #{@collection.name}"
    respond_to do |format| 
      format.html { 
        flash[:notice] = @message
        render :action => 'index'
      }
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
      format.html {
        flash[:error] = e.message
        render :action => 'index' 
      }
      format.json { 
        render :json => {
          :outcome => 'failure',
          :message => e.message,
        }.to_json 
      }
    end
  end
  
  def deactivate
    @access = @user.permissions.find(params[:id])
    @collection = @access.collection
    @access.update_attribute :active, false
    @message = "access denied to #{@collection.name}"
    respond_to do |format| 
      format.html { 
        flash[:notice] = @message
        render :action => 'index'
      }
      format.json {
        render :json => { 
          :outcome => 'inactive', 
          :message => @message 
        } 
      }
    end
  rescue => e
    respond_to do |format|
      format.html {
        flash[:error] = e.message
        render :action => 'index' 
      }
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
  
  def find_user
    @user = User.find(params[:user_id])
  end

end
