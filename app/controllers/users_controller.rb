class UsersController < AccountScopedController

  before_filter :i_am_me
  before_filter :require_account_admin, :except => [:index, :edit, :update, :show]
  before_filter :require_account_admin_or_self, :only => [:edit, :update]
  before_filter :require_account_admin_or_password_given, :only => [:update]

  skip_before_filter :require_user, :only => [:activate]
  before_filter :get_user, :only => [:activate]

  def index
    @list = current_account.users
  end

  def activate
    @thing.activate!
    render
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

  def require_account_admin_or_self
    return true if current_user.account_admin?
    return true if @thing == current_user
    false
  end
  
  def require_account_admin_or_password_given
    return true if current_user.account_admin?
    return true if @thing.valid_password?(params[:old_password])

    # might as well get any other validation messages while we're at it
    @thing.attributes = params[:thing]
    @thing.valid?
    
    flash[:error] = 'Wrong password.'
    @thing.errors.add(:old_password, "was not correct")
    render :action => 'edit'
    false
  end
  
  def get_user
    @thing = User.find_by_id_and_perishable_token(params[:id], params[:token])    #NB not using authlogic's find_using_perishable_token because I don't want the token to time out
    logger.warn "UsersController.get_user: @thing is #{@thing.inspect}"
    @thing
  end  
  
end
