class BookmarkingsController < ObjectScopedController
  
  skip_before_filter :build_item

  def create
    @bookmarked = thing_from_tag( params[:object] )
    @bookmarking = @thing.bookmarkings.create!(:bookmark => @bookmarked)
    render :partial => 'components/bookmarking_list'
  end
  
  def destroy
    @thing.bookmarkings.of(thing_from_tag(params[:object])).each { |bm| bm.delete }
    render :partial => 'components/bookmarking_list'
  end
  
end
