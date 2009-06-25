class TaggingsController < ObjectScopedController

  # when we're object-scoped, @thing is the scoping object

  # NB thing_from_tag is just a utility that converts the 
  # string source_243 into the Source object with id 243
  # nothing to do with tag objects

  before_filter :request_collection
  before_filter :get_tagging, :only => [:destroy]

  def create
    @tag = thing_from_tag( params[:object] )
    @tagging = @thing.taggings.create!(:tag => @tag)
    render :partial => 'components/tagging_list'
  end

  def destroy
    @tagging.destroy
    render :partial => 'components/tagging_list'
  end

protected

  def get_tagging
    if params[:id]
      @tagging = @thing.taggings.find(params[:id])
    end
  end

end
