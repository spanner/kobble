class MonitorshipsController < ApplicationController
  skip_before_filter :editor_required
  before_filter :activation_required

  def create
    @monitorship = Monitorship.find_or_initialize_by_user_id_and_topic_id(current_user.id, params[:topic_id])
    @monitorship.update_attribute :active, true
    respond_to do |format| 
      format.html { redirect_to topic_path(params[:forum_id], params[:topic_id]) }
      format.js { render :layout => false}
    end
  end
  
  def destroy
    Monitorship.update_all ['active = ?', false], ['user_id = ? and topic_id = ?', current_user.id, params[:topic_id]]
    respond_to do |format| 
      format.html { redirect_to topic_path(params[:forum_id], params[:topic_id]) }
      format.js { render :layout => false}
    end
  end
end
