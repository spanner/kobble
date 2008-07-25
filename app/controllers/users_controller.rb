class UsersController < ApplicationController

  before_filter :i_am_me
  before_filter :find_account
  before_filter :find_user, :except => [:new, :create]
  before_filter :build_user, :only => [:new, :create]
  before_filter :account_admin_required, :except => [:edit, :update, :show]
  before_filter :account_admin_or_self_required, :only => [:edit, :update]
  before_filter :account_admin_or_password_given, :only => [:update]
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
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def create
    @user.login = @user.email if @user.login.blank?
    if @user.save
      flash[:notice] = 'User created.'
      respond_to do |format|
        format.html { redirect_to :action => 'show', :id => @user }
        format.json { render :json => @user.to_json }
      end
    else
      render :action => 'new'
    end
  end

  def edit

  end

  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was updated.'
      respond_to do |format|
        format.html { redirect_to :action => 'show' }
        format.json { render :json => @user.to_json }
      end
    else
      flash[:error] = 'Validation problems.'
      render :action => 'edit'
    end
  end
  
  def activate
    @user.activate
    respond_to do |format|
      format.html { redirect_to :action => 'show', :id => @user }
      format.js { render :layout => false }
      format.json { render :json => @user.to_json }
    end
  end

  def deactivate
    @user.deactivate
    respond_to do |format|
      format.html { redirect_to :action => 'show', :id => @user }
      format.js { render :layout => false }
      format.json { render :json => @user.to_json }
    end
  end
  
  def predelete
    @other_users = @account.users.select{|u| u != @user}
  end
  
  def reinvite
    @user = @account.users.find(params[:id])
  end

  private
  
  def i_am_me
    params[:id] = current_user.id if params[:id] == 'me'
  end
  
  def find_account
    @account = admin? && params[:account_id] ? Account.find(params[:account_id]) : current_account
  end
  
  def find_user
    @user = account_admin? && params[:id] ? User.find(params[:id]) : current_user
  end
  
  def build_user
    @user = @account.users.build(params[:user])
  end

  def account_admin_or_self_required
    return true if current_user.account_admin?
    return true if @user == current_user
    access_insufficient
  end
  
  def account_admin_or_password_given
    return true if current_user.account_admin?
    @user.attributes = params[:user]
    return true if @user.authenticated?(@user.old_password)
    flash[:error] = 'Wrong password.'
    @user.valid?    # might as well display the other validation messages while we're there
    @user.errors.add(:old_password, "was not correct")
    render :action => 'edit'
    false
  end
  
  def admin_or_same_account_required
    return true if current_user.admin?
    return true if current_user.account == @account
    access_insufficient
  end
  
end
