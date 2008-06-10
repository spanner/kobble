class CollectionsController < ApplicationController
  
  before_filter :find_account
  before_filter :account_admin_required, :except => [:index, :show]
  before_filter :admin_or_same_account_required
  
  # only accessible as nested resource of account
  # but if no account specified then current_user's account is assumed to provide context
    
  def view_scope
    'account'
  end
  
  def new
    @collection = @account.collections.build
    respond_to do |format| 
      format.html
      format.json { render :json => @collection.to_json }
      format.js { render :layout => false }
    end
  end
  
  def create
    @collection = @account.collections.build(params[:collection])
    @collection.last_active_at = Time.now
    @collection.abbreviation = @collection.name.initials_or_beginning if @collection.abbreviation.nil? || @collection.abbreviation == ""  #defined in spoke_content plugin's StringExtensions
    if @collection.save
      current_user.permission_for(@collection).activate
      current_user.activation_of(@collection).activate
      flash[:notice] = 'Collection was created.'
      respond_to do |format| 
        format.html { redirect_to url_for(@collection) }
        format.json { render :json => @collection.to_json }
        format.js { render :layout => false }
      end
    else
      render :action => 'new'
    end
  end

  def edit
    @collection = @account.collections.find(params[:id])
    respond_to do |format| 
      format.html
      format.json { render :json => @collection.to_json }
      format.js { render :layout => false }
    end
  end

  def update
    @collection = @account.collections.find(params[:id])
    if @collection.update_attributes(params[:collection])
      flash[:notice] = 'Collection was updated.'
      respond_to do |format| 
        format.html { redirect_to :action => 'show' }
        format.json { render :json => @collection.to_json }
        format.js { render :layout => false }
      end
    else
      render :action => 'edit'
    end
  end

  private
  
  def find_account
    @account = admin? && params[:account_id] ? Account.find(params[:account_id]) : current_account
  end
  
  def admin_or_same_account_required
    return true if current_user.admin?
    return true if current_user.account == @account
    access_insufficient
  end
  




end
