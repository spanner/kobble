class UsersController < ApplicationController
  
  # this is user review and management for admins
  # logging in and registration is in account_controller

  def limit_to_active_collection
    ["collection_id = ? or status > 0", current_collection]
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
    userid = params[:id] || $current_user.id
    @user = User.find(userid)
    @users = User.find(:all)
  end

  def new
    @user = User.new
    render :action => 'signup'
  end
  
  def welcome
    render :layout => 'standard'
  end
end
