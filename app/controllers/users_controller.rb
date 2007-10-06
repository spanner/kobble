class UsersController < ApplicationController
  
  # this is user review and management for admins
  # logging in and registration is in account_controller

  def index
    list
    render :action => 'list'
  end
  
  def list
    items_per_page = 20
    sort = case params['sort']
           when "surname" then "lastname, firstname"
           when "login" then "login"
           when "email" then "email"
           when "date" then "created_at"
           else "firstname, lastname"
           end

    conditions = ["name LIKE ?", "%#{params[:query]}%"] unless params[:query].nil?

    @total = User.count(:conditions => conditions)
    @user_pages, @users = paginate :users, :order => sort, :conditions => conditions, :per_page => items_per_page

    if request.xml_http_request?
      render :partial => "items_list", :layout => false
    end
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
