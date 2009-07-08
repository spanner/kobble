class PasswordResetsController < AccountScopedController
  # layout 'outside'

  skip_before_filter :require_user
  skip_before_filter :get_working_class
  skip_before_filter :get_item
  skip_before_filter :build_item
  before_filter :get_user, :only => [:edit, :update]
  
  def new
    render
  end
  
  def create
    @user = current_account.users.find_by_email(params[:email])  
    if @user
      @user.deliver_password_reset_instructions  
      flash[:notice] = "Password reset instructions have been emailed to you." 
      render
    else  
      @error = flash[:error] = "Sorry. That email address is not known here."  
      render :action => :new  
    end  
  end

  def edit  
    if @user
      flash[:notice] = "Thank you. Please enter and confirm a new password."
    else
      flash[:error] = "Sorry: can't find you."
    end
    render
  end  

  def update  
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save  
      flash[:notice] = "Thank you. Password updated."  
      redirect_to url_for(@user)
    else  
      render :action => :edit  
    end  
  end  

private  

  def get_user
    user = User.find_using_perishable_token(params[:token])
    if user
      logger.warn "get_user: user.id is #{user.id} and params[:id] is #{params[:id]}"
    else
      logger.warn "get_user: user is #{user.inspect}"
    end
    
    @user = user if (user && user.id == params[:id].to_i)
  end  

end
