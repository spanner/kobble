class AccountController < ApplicationController
  before_filter :set_context
  before_filter :activation_required, :only => [:blog, :discussion, :questions, :me, :logout]
  skip_before_filter :editor_required  
  layout :choose_layout
  
  def choose_layout
    return current_collection.abbreviation.to_s if current_collection
    return 'login'
  end

  def index
    @pagetitle = 'welcome'
    if activated?
      logger.warn "!!! retrieving recent items"
      @blogentries = Blogentry.find(:all, :conditions => limit_to_active_collection_and_this_week(Blogentry), :include => 'creator')
      @posts = Post.find(:all, :conditions => limit_to_active_collection_and_this_week(Post), :include => 'creator')
      @questions = Question.find(:all, :conditions => limit_to_active_collection_and_this_week(Question), :include => 'creator')
    end
  end
  
  def welcome
    @pagetitle = @show_field = 'welcome'
    render :action => 'index'
  end

  def background
    @pagetitle = @show_field = 'background'
    render :action => 'index'
  end
  
  def faq
    @pagetitle = @show_field = 'faq'
    render :action => 'index'
  end
  
  def me
    @pagetitle = 'you'
    @user = current_user
  end
  
  def blog
    @pagetitle = 'blog'
    @blogentries = Blogentry.find(:all, 
      :conditions => limit_to_active_collection, 
      :page => {
        :size => 25, 
        :sort => 'date DESC', 
        :current => params[:page]
      }
    )
  end 
  
  def discussion
  end

  def questions
  end

  def blogentry
    @pagetitle = 'blog'
    @blogentry = Blogentry.find(params[:id])
    @forum = current_collection.blog_forum
    @topic = @blogentry.topics.first
    @topic.hit! unless logged_in? and @topic.created_by == current_user
    @post_pages, @posts = paginate(:posts, :per_page => 25, :order => 'posts.created_at', :include => :creator, :conditions => ['posts.topic_id = ?', @topic.id])
    @posts.shift  # remove the original post: it just duplicates the blog entry
    @post = Post.new
    @blogentries = Blogentry.find(:all, :conditions => limit_to_active_collection, :page => {:size => 6, :sort => 'date DESC'})
  end

  def signup
    @pagetitle = 'signup'
    @user = User.new(params[:user])
    return unless request.post?
    @user.save!
    @user.collection = current_collection
    @user.save
    session[:user] = @user.id
    self.current_user = @user
    session[:topics] = session[:forums] = {}
    flash[:notice] = "Thanks for signing up!"
    redirect_to :controller => '/account', :action => 'index'
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
  
  def resend_activation
    
  end

  def repassword
    @pagetitle = 'reset'
    return unless request.post?
    return @error = "Please enter an email address." unless params[:email] && !params[:email].nil? 
    @user = User.find_by_email(params[:email])
    return @error = "Sorry: The email address <strong>#{params[:email]}</strong> is not known here." unless @user
    unless (@user.activated)
      @error = "Sorry: You can't change the password for an account that hasn't been activated. We have resent the activation message instead. Clicking the activation link will log you in and allow you to change your password." 
      UserNotifier.deliver_activation(user, current_collection)
    end
    @user.provisional_new_password
    UserNotifier.deliver_newpassword(user, current_collection)
  end
  
  def fix_password
    activator = params[:id] || params[:activation_code]
    newpass = params[:password]
    redirect_to :action => 'repassword' if activator.nil?
    @user = User.find_by_activation_code(activator)
    if @user and @user.accept_new_password(newpass)
      self.current_user = @user
      redirect_to :controller => '/account', :action => 'index'
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
      redirect_back_or_default(:controller => current_user.editor? ? 'nodes' : '/')
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
    redirect_back_or_default(:controller => '/account', :action => 'index')
  end

  def forbidden
    flash[:error] = "Access Denied." 
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
