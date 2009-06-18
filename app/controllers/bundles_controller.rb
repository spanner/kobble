class BundlesController < CollectionScopedController

  # change this to pass around member set
  # not use scratchpad directly

  # should we remove items from scratchpad?
  # not necessary if we remember the selections and sustain them across page loads

  def new
    @thing = Bundle.new
    @thing.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
    get_members_from_bookmarks
  end

  def create
    @thing = Bundle.new(params[:thing])
    if @thing.save
      @thing.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
      if params[:with]
        Bundle.transaction {
          @thing.members = params[:with].collect {|bm| 
            bm = Bookmarking.find_by_id(bm)
            if bm
              bm.destroy if params[:delete_bookmarkings] 
              bm.bookmark
            end
          }
        }
        flash[:notice] = "Bundle created from selection"
      else
        flash[:notice] = 'Bundle created'
      end
      redirect_to collected_url_for(@thing)
    else
      get_members_from_bookmarks
      render :action => 'new'
    end
  end

protected

  def get_members_from_bookmarks
    @bookmarkings = []
    params[:with].each do |bmid| 
      if bm = Bookmarking.find(bmid, :include => :bookmark) rescue nil
        if bm.bookmark.is_a?(Tag)
          @thing.tags.push(bm.bookmark) 
        else
          @bookmarkings.push(bm)
        end
      end
    end
  end

end
