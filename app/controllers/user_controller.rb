class UserController < ApplicationController
  model   :user
  require 'pp';
  
  # user's active collection preference carried in collection relationship
  
  def choosecollection
    @user = User.find( session['user'].id )
    collection = Collection.find(params[:id])
    if(collection) then
      @user.collection = collection
      @user.save!
      @active_collection = collection
      redirect_to :controller => 'nodes', :action => 'index'
    else
      flash['notice'] = "no such collection?"
      render :action => 'index'
    end
  end
  
  # user management

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
    userid = params[:id] || $session['user'].id
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

  def me
    @user =User.find( session['user'].id )
    @users = User.find(:all)
    render :action => 'show', :layout => 'standard'
  end
  
  def help
    @topic = params['topic']
    render :layout => false
  end
  
  

  # standard saltedhashlogin below

  def login
    return if generate_blank
    @thisuser = User.new(params['user'])
    if session['user'] = User.authenticate(params['user']['login'], params['user']['password'])
      session['newlogin'] = true
      flash['notice'] = l(:user_login_succeeded)
      redirect_back_or_default :controller => 'nodes', :action => 'index'
    else
      @login = params['user']['login']
      flash.now['message'] = l(:user_login_failed)
    end
  end

  def signup
    # if (! session['user'])
    #   redirect_to :action => 'login'
    #   return
    # end
    logger.debug "signing up new user?"
    return if generate_blank
    
    params['user'].delete('form')
    @user = User.new(params['user'])
    begin
      User.transaction(@user) do
        @user.new_password = true
        logger.debug "saving user #{params[:user][:firstname]}"
        if @user.save!
          logger.debug "saved"
          key = @user.generate_security_token
          url = url_for(:controller => 'nodes')
          url += "?user[id]=#{@user.id}&key=#{key}"
          UserNotify.deliver_signup(@user, params['user']['password'], url)
          flash['notice'] = l(:user_signup_succeeded)
          redirect_to :action => 'login'
        end
      end
    rescue
      logger.info "failed transaction: #{$!}"
      logger.warn(pp(@user))
      flash.now['message'] = l(:user_confirmation_email_error)
    end
  end  
  
  def logout
    session['user'] = nil
    redirect_to :action => 'login'
  end

  def change_password
    return if generate_filled_in
    params['user'].delete('form')
    begin
      User.transaction(@user) do
        @user.change_password(params['user']['password'], params['user']['password_confirmation'])
        if @user.save
          UserNotify.deliver_change_password(@user, params['user']['password'])
          flash.now['notice'] = l(:user_updated_password, "#{@user.email}")
        end
      end
    rescue
      flash.now['message'] = l(:user_change_password_email_error)
    end
  end

  def forgot_password
    # Always redirect if logged in
    if user?
      flash['message'] = l(:user_forgot_password_logged_in)
      redirect_to :action => 'change_password'
      return
    end

    # Render on :get and render
    return if generate_blank

    # Handle the :post
    if params['user']['email'].empty?
      flash.now['message'] = l(:user_enter_valid_email_address)
    elsif (user = User.find_by_email(params['user']['email'])).nil?
      flash.now['message'] = l(:user_email_address_not_found, "#{params['user']['email']}")
    else
      begin
        User.transaction(user) do
          key = user.generate_security_token
          url = url_for(:action => 'change_password')
          url += "?user[id]=#{user.id}&key=#{key}"
          UserNotify.deliver_forgot_password(user, url)
          flash['notice'] = l(:user_forgotten_password_emailed, "#{params['user']['email']}")
          unless user?
            redirect_to :action => 'login'
            return
          end
          redirect_back_or_default :action => 'welcome'
        end
      rescue
        flash.now['message'] = l(:user_forgotten_password_email_error, "#{params['user']['email']}")
      end
    end
  end

  def edit
    return if generate_filled_in
    if params['user']['form']
      form = params['user'].delete('form')
      begin
        case form
        when "edit"
          changeable_fields = ['firstname', 'lastname']
          params = params['user'].delete_if { |k,v| not changeable_fields.include?(k) }
          @user.attributes = params
          @user.save
        when "change_password"
          change_password
        when "delete"
          delete
        else
          raise "unknown edit action"
        end
      end
    end
  end

  def delete
    @user = session['user']
    begin
      if UserSystem::CONFIG[:delayed_delete]
        User.transaction(@user) do
          key = @user.set_delete_after
          url = url_for(:action => 'restore_deleted')
          url += "?user[id]=#{@user.id}&key=#{key}"
          UserNotify.deliver_pending_delete(@user, url)
        end
      else
        destroy(@user)
      end
      logout
    rescue
      flash.now['message'] = l(:user_delete_email_error, "#{@user['email']}")
      redirect_back_or_default :action => 'welcome'
    end
  end

  def restore_deleted
    @user = session['user']
    @user.deleted = 0
    if not @user.save
      flash.now['notice'] = l(:user_restore_deleted_error, "#{@user['login']}")
      redirect_to :action => 'login'
    else
      redirect_to :action => 'welcome'
    end
  end

  protected

  def destroy(user)
    UserNotify.deliver_delete(user)
    flash['notice'] = l(:user_delete_finished, "#{user['login']}")
    user.destroy()
  end

  def protect?(action)
    if ['login', 'signup', 'forgot_password'].include?(action)
      return false
    else
      return true
    end
  end

  # Generate a template user for certain actions on get
  def generate_blank
#    logger.debug "generate_blank!"
    case request.method
    when :get
      @user = User.new
      render
      return true
    end
    return false
  end

  # Generate a template user for certain actions on get
  def generate_filled_in
#    logger.debug "generate_filled_in!"
    @user = session['user']
    case request.method
    when :get
      render
      return true
    end
    return false
  end
end
