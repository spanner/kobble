class AccountController < ApplicationController
  before_filter :set_context
  skip_before_filter :editor_required  
  before_filter :activation_required, :only => [:blog, :blogentry, :discussion, :questions, :me, :logout]
  before_filter :admin_required, :only => [:choose_collection]
  layout :choose_layout
  
  def choose_layout
    return current_collection.abbreviation.to_s if current_collection
    return 'login'
  end

  # low-ranking users get controlled access to content through this controller

  def index
    @pagetitle = 'welcome'
    if activated?
      logger.warn "!!! retrieving recent items"
      @blogentries = Blogentry.find(:all, :conditions => limit_to_active_collection_and_this_week(Blogentry), :include => 'creator')
      @topics = Topic.find(:all, :conditions => limit_to_active_collection_and_this_week(Topic), :include => 'creator')
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
      :order => 'created_at DESC', 
      :page => {
        :size => 25, 
        :current => params[:page]
      }
    )
  end 
  
  def discussion
    @pagetitle = 'discussion'
    @discussions = Forum.find(:all, 
      :conditions => ["forums.collection_id = ? and forums.visibility <= ? and forums.id != ?", current_collection, current_user.status, current_collection.blog_forum_id], 
      :order => 'name ASC', 
      :page => {
        :size => 25, 
        :current => params[:page]
      }
    )
  end

  def blogentry
    @pagetitle = 'blog'
    @blogentries = Blogentry.find(:all, 
      :conditions => limit_to_active_collection, 
      :order => 'created_at DESC', 
      :page => {
        :size => 6,
        :current => params[:page]
      }
    )
    @blogentry = Blogentry.find(params[:id])
    @forum = current_collection.blog_forum
    @topic = @blogentry.topics.first
    @topic.hit! unless logged_in? and @topic.created_by == current_user
    @monitoring = !Monitorship.count(:all, :conditions => ['user_id = ? and topic_id = ? and active = ?', current_user.id, @topic.id, true]).zero?
    perpage = params[:perpage] || 25
    @posts = Post.find(:all, 
      :include => :creator, 
      :conditions => ['posts.topic_id = ?', @topic.id], 
      :page => {:size => perpage, :sort => 'posts.created_at', :current => params[:page]})
    @post = Post.new
    @omit_first = @topic.posts.first
  end

  def limit_to_active_collection_and_group(group)
    ["users.collection_id = ? or users.status >= 200", current_collection]
  end

  def survey
    @pagetitle = 'survey'

    @question = Question.find(params[:id]) if params[:id]
    @question.nil! if @question && @question.collection != current_collection
    
    @questions = current_user.user_group.nil? ? 
      Question.find(:all, :conditions => limit_to_active_collection) : 
      Question.find(:all, :conditions => ["questions.collection_id = ? and (questions.user_group = ? OR questions.user_group is NULL)", current_collection, current_user.user_group])

    @question = @questions.select{|q| q.answer_from(current_user).nil? }.first if @question.nil?
    @questions.delete(@question) unless @question.nil?

    @answer = Answer.new
    @answer.speaker = current_user
    @answer.question = @question
  end

  def answer
    @pagetitle = 'survey'
    @question = Question.find(params[:id])
    @answer = Answer.new(params[:answer])
    @answer.speaker = current_user
    @answer.question = @question
    if @answer.save
      flash[:notice] = "Thank you! Your answer has been recorded."
      redirect_to :action => 'survey'
    else 
      render :action => 'survey'
    end
  end


  # registration, login and account-control

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
    flash[:notice] = "Registration processed."
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
    unless (@user.activated?)
      UserNotifier.deliver_signup_notification(@user, current_collection)
      return @error = "Sorry: You can't change the password for an account that hasn't been activated. We have resent the activation message instead. Clicking the activation link will log you in and allow you to change your password." 
    end
    newpass = @user.provisional_new_password
    UserNotifier.deliver_newpassword(@user, current_collection)
  end
  
  def fixpassword
    activator = params[:id] || params[:activation_code]
    redirect_to :action => 'repassword' if activator.nil?
    @user = User.find_by_activation_code(activator)
    if @user and @user.accept_new_password
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
