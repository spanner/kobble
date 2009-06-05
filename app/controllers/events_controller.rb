class EventsController < CollectionScopedController

  def index
    @user = current_account.users.find(params[:user_id]) if params[:user_id]
    @thing = @user || current_collection
    if params[:type] && ['created', 'updated', 'deleted'].include?(params[:type])
      @events = @thing.events.of_type(params[:type]).paginate(self.paging)
    else
      @events = @thing.events.paginate(self.paging)
    end
  end
  
end
