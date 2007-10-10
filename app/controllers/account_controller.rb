class AccountController < ApplicationController
  skip_before_filter :login_required
  
  def index
    # redirect_to(:action => 'login') unless logged_in?
  end

  def set_context
    Collection.current_collection = UserObserver.current_collection = @current_collection = Collection.find(params[:id] || 2)
  end
  
  def signup
    @user = LoginUser.new(params[:user])
    return unless request.post?
    @user.save!
    @user.collection = @current_collection
    @user.save
    self.current_user = @user
    redirect_to :controller => '/account', :action => 'index'
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def activate
    flash.clear  
    return if params[:id].nil? and params[:activation_code].nil?
    activator = params[:id] || params[:activation_code]
    @user = User.find_by_activation_code(activator) 
    if @user and @user.activate
      self.current_user = @user
      redirect_to :controller => '/account', :action => 'index'
      flash[:notice] = "Your account has been activated." 
    else
      flash[:error] = "Unable to activate your account. Please check activation code." 
    end
  end  

  def login
    return unless request.post?
    self.current_user = LoginUser.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/')
      flash[:notice] = "Logged in successfully"
    end
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/account', :action => 'index')
  end

  # user's active collection preference is carried in collection relationship
  
  def choosecollection
    collection = Collection.find(params[:id])
    if(current_user && collection) then
      current_user.collection = collection
      current_user.save!
      redirect_to :controller => 'nodes', :action => 'index'
    else
      flash['notice'] = "no such collection?"
      render :action => 'index'
    end
  end
end
