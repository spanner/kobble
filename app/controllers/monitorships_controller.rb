class MonitorshipsController < ApplicationController
  skip_before_filter :editor_required
  before_filter :activation_required

  def toggle
    @monitorship = Monitorship.find(params[:id])
    if @monitorship.active?
      deactivate
    else 
      activate
    end
  end
  
  def activate
    @monitorship.update_attribute :active, true
    @message = "topic subscription confirmed"
    respond_to do |format| 
      format.html { 
        flash[:notice] = @message
        redirect_to :controller => 'accounts', :action => 'home' 
      }
      format.json {
        render :json => { 
          :outcome => 'active', 
          :message => @message 
        } 
      }
    end
  rescue => e
    respond_to do |format|
      format.html { 
        flash[:error] = e.message
        redirect_to url_for(@monitorship.topic)
      }
      format.json { 
        render :json => {
          :outcome => 'failure',
          :message => e.message,
        }.to_json 
      }
    end
  end
  
  def deactivate
    @monitorship.update_attribute :active, false
    @message = "topic subscription disabled"
    respond_to do |format| 
      format.html { 
        flash[:notice] = @message
        redirect_to url_for(@monitorship.topic)
      }
      format.json {
        render :json => { 
          :outcome => 'inactive', 
          :message => @message 
        } 
      }
    end
  rescue => e
    respond_to do |format|
      format.html { 
        flash[:error] = e.message
        redirect_to url_for(@monitorship.topic)
      }
      format.json { 
        render :json => {
          :outcome => 'failure',
          :message => e.message,
        }.to_json 
      }
    end
  end

  def create
    @monitorship = Monitorship.find_or_initialize_by_user_id_and_topic_id(current_user.id, params[:topic_id])
    activate
  end
  
  def destroy
    @monitorship = Monitorship.find_or_initialize_by_user_id_and_topic_id(current_user.id, params[:topic_id])
    deactivate
  end

end
