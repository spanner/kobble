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

  def view_scope
    'account'
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
    @user.login ||= @user.email
    if @user.save
      flash[:notice] = 'User created.'
      respond_to do |format|
        format.html { redirect_to :action => 'index' }
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
        format.html { redirect_to :action => 'show' }
        format.json { render :json => @user.to_json }
      end
    else
      render :action => 'edit'
    end
  end
  
  def activate
    @user = @account.users.find(params[:id])
    @user.activate
    respond_to do |format|
      format.html { redirect_to :action => 'show', :id => @user }
      format.js { render :layout => false }
      format.json { render :json => @user.to_json }
    end
  end

  def deactivate
    @user = @account.users.find(params[:id])
    @user.deactivate
    respond_to do |format|
      format.html { redirect_to :action => 'show', :id => @user }
      format.js { render :layout => false }
      format.json { render :json => @user.to_json }
    end
  end
  
  def predelete
    @user = @account.users.find(params[:id])
    @other_users = @account.users.select{|u| u != @user}
  end
  
  private
  
  def find_account
    @account = admin? && params[:account_id] ? Account.find(params[:account_id]) : current_account
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
