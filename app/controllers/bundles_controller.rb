class BundlesController < CollectedController

  # change this to pass around member set
  # not use scratchpad directly

  # should we remove items from scratchpad?
  # not necessary if we remember the selections and sustain them across page loads

  def new
    @thing = Bundle.new
    @thing.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
    if params[:scratchpad_id] && @expad = Scratchpad.find(params[:scratchpad_id])
      @members = @expad.scraps.uniq
      @thing.name = @expad.name if @bundle.name.blank?
      @thing.body = @expad.body if @bundle.body.blank?
    end
  end

  def create
    @thing = Bundle.new(params[:bundle])
    @expad = Scratchpad.find(params[:scratchpad_id]) if params[:scratchpad_id]
    if @thing.save
      @thing.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
      if @expad
        Bundle.transaction {
          @thing.members = @expad.scraps.uniq
          @expad.destroy
        }
        flash[:notice] = "Bundle created from scratchpad #{@expad.name}"
      else
        flash[:notice] = 'Bundle created'
      end
      redirect_to url_for @bundle
    else
      render :action => 'new'
    end
  end

end
