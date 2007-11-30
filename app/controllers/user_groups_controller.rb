class UserGroupsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :create, :update, :preview_message, :message ],
         :redirect_to => { :action => :list }

  def list
    @user_group_pages, @user_groups = paginate :user_groups, :per_page => 10
  end
  
  def limit_to_active_collection_and_group(ug)
    ["users.collection_id = ? and users.user_group_id = ?", current_collection, ug.id]
  end

  def show
    @user_group = UserGroup.find(params[:id])
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
      :conditions => limit_to_active_collection_and_group(@user_group), 
      :order => sort, 
      :page => {
        :size => perpage, 
        :current => params[:page]
      })
  end

  def new
    @user_group = UserGroup.new
  end

  def create
    @user_group = UserGroup.new(params[:user_group])
    if @user_group.save
      flash[:notice] = 'UserGroup was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @user_group = UserGroup.find(params[:id])
  end

  def update
    @user_group = UserGroup.find(params[:id])
    if @user_group.update_attributes(params[:user_group])
      flash[:notice] = 'UserGroup was successfully updated.'
      redirect_to :action => 'show', :id => @user_group
    else
      render :action => 'edit'
    end
  end

  def destroy
    UserGroup.find(params[:id]).destroy
    redirect_to :controller => 'users', :action => 'list'
  end

  def preview_message
    @user_group = UserGroup.find(params[:id])
    @recipients = @user_group.notifiable
    respond_to do |format|
      format.html { }
      format.js { render :layout => false }
    end
  end
  
  def send_message
    @user_group = UserGroup.find(params[:id])
    @recipients = []
    @user_group.notifiable.each do |u|
      UserGroupNotifier.deliver_message(u, @user_group, Collection.current_collection, params[:title], CGI::unescape(params[:message]))
      @recipients << u
    end
    flash[:notice] = "Message delivered to #{@recipients.size} user(s)"
    respond_to do |format|
      format.html { redirect_to :action => 'show', :id => @user_group and return }
      format.js { render :layout => false }
    end
  end

end
