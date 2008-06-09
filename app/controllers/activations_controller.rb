class ActivationsController < ApplicationController

  skip_before_filter :check_activations  

  def toggle
    @activation = Activation.find(params[:id])
    if @activation.active?
      deactivate
    else 
      activate
    end
  end
  
  def activate
    @activation = Activation.find(params[:id])
    @collection = @activation.collection
    # raise "you don't have permission to access that collection" unless current_user.has_permission?(@collection)
    @activation.update_attribute :active, true
    @message = "#{@collection.name} activated"
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
    @activation = Activation.find(params[:id])
    @collection = @activation.collection
    @activation.update_attribute :active, false
    @message = "#{@collection.name} deactivated"
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
