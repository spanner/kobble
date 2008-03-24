class ActivationsController < ApplicationController

  def toggle
    @activation = Activation.find_or_initialize_by_user_id_and_collection_id(current_user.id, params[:collection_id])
    @activation.update_attribute :active, @activation.active ? false : true
    respond_to do |format| 
      format.html { redirect_to :controller => 'users', :action => 'home' }
      format.js { render :layout => false }
    end
  end
  
  def activate
    @activation = Activation.find_or_initialize_by_user_id_and_collection_id(current_user.id, params[:collection_id])
    @activation.update_attribute :active, true
    respond_to do |format| 
      format.html { redirect_to :controller => 'users', :action => 'home' }
      format.js { render :layout => false }
    end
  end
  
  def deactivate
    Activation.update_all ['active = ?', false], ['user_id = ? and collection_id = ?', current_user.id, params[:collection_id]]
    respond_to do |format| 
      format.html { redirect_to :controller => 'users', :action => 'home' }
      format.js { render :layout => false}
    end
  end
  
  def create
    activate
  end
  
  def destroy
    deactivate
  end

end
