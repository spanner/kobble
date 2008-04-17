class UserPreferencesController < ApplicationController

  def toggle
    @up = UserPreference.find(params[:id])
    if @up.active?
      deactivate
    else 
      activate
    end
  end
  
  def activate
    @up = UserPreference.find(params[:id])
    @preference = @up.preference
    @up.update_attribute :active, true
    @message = "#{@preference.name} activated"
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
    flash[:error] = e.message
    respond_to do |format|
      format.html { redirect_to :controller => 'accounts', :action => 'home' }
      format.json { 
        render :json => {
          :outcome => 'failure',
          :message => e.message,
        }.to_json 
      }
    end
  end
  
  def deactivate
    @up = UserPreference.find(params[:id])
    @preference = @up.preference
    @up.update_attribute :active, false
    @message = "#{@preference.name} deactivated"
    respond_to do |format| 
      format.html { 
        flash[:notice] = @message
        redirect_to :controller => 'accounts', :action => 'home' 
      }
      format.json {
        render :json => { 
          :outcome => 'inactive', 
          :message => @message 
        } 
      }
    end
  rescue => e
    flash[:error] = e.message
    respond_to do |format|
      format.html { redirect_to :controller => 'accounts', :action => 'home' }
      format.json { 
        render :json => {
          :outcome => 'failure',
          :message => e.message,
        }.to_json 
      }
    end
  end
  
  def create
    activate
  end
  
  def destroy
    deactivate
  end

end
