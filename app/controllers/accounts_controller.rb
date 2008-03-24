class AccountsController < ApplicationController
  before_filter :admin_required, :except => [:show, :edit, :update, :create, :new]
  before_filter :login_required, :except => [:create, :new]

  def index
    home
    render :action => 'home'
  end

  def home
    @account = current_user.account
  end

  def show
    @account = admin? ? Account.find(params[:id]) : current_user.account
  end

  def limit_to_active_collections(klass=nil)
    []
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
    @account = admin? ? Account.find(params[:id]) : current_user.account
  end

  def update
    @account = admin? ? Account.find(params[:id]) : current_user.account
    
    # check permission to change
    
    if @collection.update_attributes(params[:collection])
      flash[:notice] = 'Collection was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @account = admin? ? Account.find(params[:id]) : current_user.account
  end

  def reallydestroy
    @account = admin? ? Account.find(params[:id]) : current_user.account
    
    # check permission to change
    
    @account.destroy
    flash[:notice] = "account removed"
    redirect_to :action => 'list'
  end
end
