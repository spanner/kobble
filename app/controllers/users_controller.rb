class UsersController < ApplicationController

  before_filter :editor_required, :except => [:edit, :update]
  before_filter :activation_required, :only => [:edit, :update, :show]
  
  # this is user review and management for admins
  # logging in and registration is in account_controller

  def limit_to_active_collection
    ["users.collection_id = ? or users.status >= 200", current_collection]
  end

  def index
    list
    render :action => 'list'
  end
  
  def list
    @display = case params['display']
      when "thumb" then "thumb"
      when "slide" then "slide"
      else "list"
    end
    perpage = params[:perpage] || (@display == 'thumb') ? 100 : 40
    sort = case params['sort']
           when "login" then "login"
           when "status" then "status DESC"
           when "email" then "email"
           when "date" then "created_at DESC"
           when "firstname" then "firstname, lastname"
           else "lastname, firstname"
           end

    @users = User.find(:all, 
      :conditions => limit_to_active_collection, 
      :order => sort, 
      :page => {
        :size => perpage, 
        :current => params[:page]
      }
    )
  end
  
  def show
    userid = params[:id] || current_user.id
    @user = User.find(userid)
    @users = User.find(:all)
    unless editor?
      render :template => 'account/me' and return
    end
  end

  def new
    @user = User.new
    respond_to do |format|
      format.html
      format.js { render :layout => false, :template => 'users/new_inline' }
    end
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'User created.'
      respond_to do |format|
        format.html { render :action => 'show' }
        format.js { render :layout => false, :template => 'users/created_inline' }
      end
    else
      render :action => 'new'
    end
  end

  def edit
    userid = (current_user.editor? ? params[:id] : nil) || current_user.id
    @pagetitle = 'you' unless current_user.editor? || userid == current_user.id
    @user = User.find(userid)
  end

  def update
    if (current_user.editor?)
      userid = params[:id] || current_user.id
    else
      userid = current_user[:id]
    end
    @user = User.find(userid)
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was updated.'
      redirect_to (current_user.editor? ? {:action => 'show', :id => @user} : {:controller => 'account', :action => 'me'})
    else
      flash[:notice] = 'failed to update.'
      render :action => 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    respond_to do |format|
      format.html do
        redirect_to :action => 'list'
      end
      format.js { render :nothing => true }
      format.xml { head 200 }
    end
  end
  
  def activate
    @user = User.find(params[:id])
    @user.activate
    respond_to do |format|
      format.html { redirect_to :action => 'show', :id => @user }
      format.js { render :layout => false }
      format.xml { head 200 }
    end
  end

  def deactivate
    @user = User.find(params[:id])
    @user.deactivate
    respond_to do |format|
      format.html { redirect_to :action => 'show', :id => @user }
      format.js { render :layout => false }
      format.xml { head 200 }
    end
  end

end
