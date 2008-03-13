class AccountsController < ApplicationController
  layout :choose_layout
  before_filter :admin_required, :except => [:show, :edit, :update, :create, :new]

  def show
    @account = admin? ? Account.find(params[:id]) : current_user.account
  end

  def limit_to_active_collections(klass=nil)
    []
  end

  def new
    @collection = Account.new
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
