class AccountsController < ApplicationController
  skip_before_filter :check_activations  
  before_filter :admin_or_owner_required, :except => [:create, :new, :home]

  def index
    home
    render :action => 'home'
  end

  def show
    home
    render :action => 'home'
  end

  def home
    @account = current_user.account
    @collections = current_account.collections_by_activity
    case params[:since]
    when 'today'
      @since = Time.now.beginning_of_day
    when 'week'
      @since = 1.week.ago
    when 'month'
      @since = 1.month.ago
    when 'login'
      @since = current_user.previously_logged_in_at
    else
      @since = nil
    end
  end

  def show
    @thing = admin? ? Account.find(params[:id]) : current_user.account
  end

  def new
    @account = Account.new(params[:account])
    @user = User.new(params[:user])
    if request.post?
      @user.status = 0
      @user.save!
      session[:user] = @user.id
      self.current_user = @user
      flash[:notice] = "Registration processed."
      redirect_to :controller => '/login', :action => 'index'
    end
    render :layout => 'login'
  rescue ActiveRecord::RecordInvalid
    @known_user = User.find_by_email(@user.email)
    render :action => 'new', :layout => 'login'
  end

  def create
    @account = Account.new(params[:account])
    if @account.save
      flash[:notice] = 'Account was successfully created.'
      redirect_to :action => 'show', :id => @account
    else
      render :action => 'new'
    end
  end

  def edit
    @account = Account.find(params[:id])
  end

  def update
    @account = Account.find(params[:id])
    if @account.update_attributes(params[:account])
      flash[:notice] = 'account was successfully updated.'
      redirect_to :action => 'home'
    else
      render :action => 'edit'
    end
  end
  
  def permissions
    @account = Account.find(params[:id]) if admin?
    @account ||= current_account
  end

  private
  
  def admin_or_owner_required
    return true if current_user.admin?
    @account = Account.find(params[:id])
    return true if @account && @account.user == current_user
    access_insufficient
  end

end
