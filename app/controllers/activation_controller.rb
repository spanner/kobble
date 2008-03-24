class ActivationController < ApplicationController

  def create
    @activation = Activation.find_or_initialize_by_user_id_and_collection_id(current_user.id, params[:collection_id])
    @activation.update_attribute :active, true
    respond_to do |format| 
      format.html { redirect_to :controller => 'accounts', :action => 'home' }
      format.js { render :layout => false }
    end
  end
  
  def destroy
    Activation.update_all ['active = ?', false], ['user_id = ? and collection_id = ?', current_user.id, params[:collection_id]]
    respond_to do |format| 
      format.html { redirect_to :controller => 'accounts', :action => 'home' }
      format.js { render :layout => false}
    end
  end

end
