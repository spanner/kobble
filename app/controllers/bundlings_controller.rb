class BundlingsController < ObjectScopedController

  def create
    @member = thing_from_tag( params[:object] )
    @bundling = @thing.contained_bundlings.create!(:member => @member)
    render :partial => 'components/bundling_list'
  end

  def destroy
    @thing.bundlings.of(thing_from_tag(params[:item])).each { |t| t.delete }
    render :partial => 'components/bundling_list'
  end
  
end
