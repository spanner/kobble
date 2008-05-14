class UsersController < ApplicationController

  before_filter :find_account
  before_filter :account_admin_required, :except => [:edit, :update, :show]
  before_filter :account_admin_or_self_required, :only => [:edit, :update]
  before_filter :admin_or_same_account_required
  
  def list_columns
    4
  end

  def list_length
    80
  end

  # this is user review and management for admins
  # only accessible as nested resource of account
  # logging in and registration are in account_controller

  def index
    @users = @account.users
    respond_to do |format| 
      format.html
      format.json { render :json => @users.to_json }
    end
  end

  def show
    userid = params[:id] || current_user.id
    @user = @account.users.find(userid)
  end

  def new
    @user = @account.users.build
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def create
    @user = @account.users.build(params[:user])
    if @user.save
      flash[:notice] = 'User created.'
      respond_to do |format|
        format.html { render :action => 'show' }
        format.json { render :json => @user.to_json }
      end
    else
      render :action => 'new'
    end
  end

  def edit
    @user = @account.users.find(params[:id])
  end

  def update
    @user = @account.users.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was updated.'
      respond_to do |format|
        format.html { render :action => 'show' }
        format.json { render :json => @user.to_json }
      end
    else
      flash[:notice] = 'failed to update.'
      render :action => 'edit'
    end
  end

  def destroy
    @user = @account.users.delete(params[:id])
    respond_to do |format|
      format.html do
        flash[:notice] = 'User was removed'
        redirect_to :action => 'list'
      end
      format.js { render :nothing => true }
      format.json { render :json => @user.to_json }
      format.xml { head 200 }
    end
  end
  
  def activate
    @user = @account.users.find(params[:id])
    @user.activate
    respond_to do |format|
      format.html { redirect_to :action => 'show', :id => @user }
      format.js { render :layout => false }
      format.json { render :json => @user.to_json }
      format.xml { head 200 }
    end
  end

  def deactivate
    @user = @account.users.find(params[:id])
    @user.deactivate
    respond_to do |format|
      format.html { redirect_to :action => 'show', :id => @user }
      format.js { render :layout => false }
      format.json { render :json => @user.to_json }
      format.xml { head 200 }
    end
  end
  
  private
  
  def find_account
    @account = Account.find(params[:account_id])
  end
  
  def account_admin_or_self_required
    return true if current_user.account_admin?
    params[:id] == current_user.id ? true : access_insufficient
  end
  
  def admin_or_same_account_required
    return true if current_user.admin?
    return true if current_user.account == @account
    access_insufficient
  end
  
end
