class AccountsController < AccountScopedController
  
  skip_before_filter :require_user, :only => [:index, :new, :create]
  skip_before_filter :require_account, :only => [:index, :new, :create]
  before_filter :require_no_account, :only => [:new, :create] 
  before_filter :require_admin_or_owner, :except => [:index, :create, :new, :home]
  layout :choose_layout
  
  def index
    if current_account
      if current_user
        home
      else
        redirect_to new_user_session_url
      end
    end
    # index view is the main promotional front page
  end
  
  def home
    @account = current_account
    @collections = current_user.collections_available.sort_by{ |collection| collection.last_event_at }.reverse
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
    render :action => 'show'
  end

  def show
    @account = current_account
    @collections = current_user.collections_available.sort_by{ |collection| collection.last_event_at }.reverse
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
    @account = current_user.admin? && params[:id] ? Account.find(params[:id]) : current_account
  end

  def new
    @account = Account.new(params[:account])
    @account.account_type = AccountType.find_by_name('personal')
    @user = User.new(params[:user])
  end

  def create
    @account = Account.new(params[:account])
    @user = User.new(params[:user])
    if request.post?
      @user.save!
      session[:user] = @user.id
      self.current_user = @user
      flash[:notice] = "Registration processed."
      redirect_to :action => 'home'
    end
  rescue ActiveRecord::RecordInvalid
    @known_user = User.find_by_email(@user.email)
    render :action => 'new'
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
    @account = Account.find(params[:id]) if current_user.admin?
    @account ||= current_account
  end

protected

  def choose_layout
    current_user ? 'inside' : 'outside'
  end

private
  
  def require_admin_or_owner
    return true if current_user.admin?
    return true if current_account.user == current_user
    access_insufficient
  end

end
