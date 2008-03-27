class LoginController < ApplicationController

  before_filter :set_context
  skip_before_filter :login_required  
  layout 'login'
  
  def index
    render :action => 'index'
  end
  
  def activate
    flash.clear 
    if params[:id].nil? && params[:activation_code].nil? then
      render :action => 'activate'
    end
    activator = params[:id] || params[:activation_code]
    @user = User.find_by_activation_code(activator)
    if @user and @user.activate
      current_user = @user
      redirect_to :controller => '/login', :action => 'index'
      flash[:notice] = "Your login has been activated."
    else
      flash[:error] = "Unable to activate your account. Please check activation code."
      render :action => 'activate'
    end
  end
  
  def repassword
    @pagetitle = 'reset'
    return unless request.post?
    return @error = "Please enter an email address." unless params[:email] && !params[:email].nil? 
    @user = User.find_by_email(params[:email])
    unless @user
      flash[:error] = "Sorry: The email address <strong>#{params[:email]}</strong> is not known here."
      render :action => 'repassword'
    end
    unless (@user.activated?)
      UserNotifier.deliver_welcome(@user)
      return @error = "Sorry: You can't change the password for an account that hasn't been activated. We have resent the activation message instead. Clicking the activation link will log you in and allow you to change your password." 
    end
    newpass = @user.provisional_new_password
    UserNotifier.deliver_newpassword(@user)
  end
  
  def fixpassword
    activator = params[:id] || params[:activation_code]
    redirect_to :action => 'repassword' if activator.nil?
    @user = User.find_by_activation_code(activator)
    if @user and @user.accept_new_password
      self.current_user = @user
      redirect_to :controller => '/login', :action => 'index'
      flash[:notice] = "Your password has been reset. Click on the 'you' tab to change it to something more memorable." 
    else
      flash[:error] = "Unable to reset your password. Please check activation code." 
    end
  end

  def login
    @pagetitle = 'login'
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => 'accounts', :action => 'home')
      flash[:notice] = "Logged in successfully"
    else
      @error = true
    end
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/login', :action => 'login')
  end
  
  def preferences 
    
  end

  def forbidden
    flash[:error] = "Access Denied." 
  end

end
