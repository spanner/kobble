class BookmarkingsController < ObjectScopedController
  
  before_filter :request_collection
  before_filter :get_bookmarking, :only => [:destroy]

  def create
    @bookmarked = thing_from_tag( params[:object] )
    @bookmarking = @thing.bookmarkings.create!(:bookmark => @bookmarked)
    render :partial => 'components/bookmarking_list'
  end
  
  def destroy
    @bookmarking.destroy
    render :partial => 'components/bookmarking_list'
  end
  
protected
  
  def get_bookmarking
    @bookmarking = @thing.bookmarkings.find(params[:id])
  end
  
end
