class EventsController < ApplicationController
  before_filter :find_account_or_collection_or_user

  def index
    @thing = @collection || @user || @account
    if params[:type] && ['created', 'updated', 'deleted'].include?(params[:type])
      @events = @thing.events.of_type(params[:type]).paginate(self.paging)
    else
      @events = @thing.events.paginate(self.paging)
    end
  end

  def show
    @thing = @account.events.find(params[:id])
  end
  
  def views
    ['index']
  end

  private
  
  def find_account_or_collection_or_user
    if params[:account_id]
      access_insufficient unless admin?
      @account = Account.find(params[:account_id])
    else
      @account = current_account
    end
    if params[:collection_id]
      @collection = @account.collections.find(params[:collection_id])
    end
    if params[:user_id]
      @user = @account.users.find(params[:user_id])
    end
  end
  
end
