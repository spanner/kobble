class UsersController < AccountScopedController

  before_filter :i_am_me
  before_filter :require_account_admin, :except => [:index, :edit, :update, :show]
  before_filter :require_account_admin_or_password_given, :only => [:update]

  def view_scope
    'account'
  end

  def index
    @list = current_account.users
  end

  def activate
    @thing.activate
    respond_to do |format|
      format.html { redirect_to :action => 'show', :id => @thing }
      format.js { render :layout => false }
      format.json { render :json => @thing.to_json }
    end
  end

  def deactivate
    @thing.deactivate
    respond_to do |format|
      format.html { redirect_to :action => 'show', :id => @thing }
      format.js { render :layout => false }
      format.json { render :json => @thing.to_json }
    end
  end
  
  def predelete
    @other_users = current_account.users.other_than(@thing)
  end
  
  def reinvite
    if request.post?
      @thing.update_attributes(params[:user])
      @thing.save
      UserNotifier.deliver_invitation(@thing, current_user)
      flash[:notice] = 'Invitation message was sent.'
      @thing = @thing
      render :action => 'show'
    end
  end

private
  
  def i_am_me
    params[:id] = current_user.id if params[:id] == 'me'
  end
    
  def build_user
    @thing = current_account.users.build(params[:user])
  end

  def account_admin_or_self_required
    return true if current_user.account_admin?
    return true if @thing == current_user
    access_insufficient
  end
  
  def require_account_admin_or_password_given
    return true if current_user.account_admin?
    @thing.attributes = params[:user]
    return true if @thing.authenticated?(@thing.old_password)
    flash[:error] = 'Wrong password.'
    @thing.valid?    # might as well display the other validation messages while we're there
    @thing.errors.add(:old_password, "was not correct")
    render :action => 'edit'
    false
  end
  
end
