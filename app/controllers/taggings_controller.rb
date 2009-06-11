class TaggingsController < ObjectScopedController

  # NB thing_from_tag is just a utility that converts the 
  # string source_243 into the Source object with id 243
  # nothing to do with tag objects

  def create
    @tag = thing_from_tag( params[:object] )
    @tagging = @thing.taggings.create!(:tag => @tag)
    render :partial => 'components/tagging_list'
  end

  def destroy
    @thing.taggings.of(thing_from_tag(params[:item])).each { |t| t.delete }
    render :partial => 'components/tagging_list'
  end
  
end
