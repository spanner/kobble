class BundlingsController < ObjectScopedController

  before_filter :get_bundling, :only => [:destroy]

  def create
    @member = thing_from_tag( params[:object] )
    @bundling = @thing.contained_bundlings.create!(:member => @member)
    render :partial => 'components/bundling_list'
  end
  
  def destroy
    @bundling.destroy
    render :partial => 'components/bundling_list'
  end

protected

  def get_bundling
    if params[:id]
      @bundling = @thing.contained_bundlings.find(params[:id])
    end
  end


end
