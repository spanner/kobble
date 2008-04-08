class TopicsController < ApplicationController

  def views
    ['latest']
  end
  
  def show
    @topic = Topic.find(params[:id])
    page = params[:page] || 1
    perpage = params[:perpage] || 25
    respond_to do |format|
      format.html do
        @monitoring = !Monitorship.count(:all, :conditions => ['user_id = ? and topic_id = ? and active = ?', current_user.id, @topic.id, true]).zero?
        @posts = Post.paginate(:all, 
          :page => page, 
          :per_page => perpage,
          :include => :creator, 
          :conditions => ['posts.topic_id = ?', params[:id]], 
          :order => 'posts.created_at'
        )
        @reply = Post.new
      end
      format.rss do
        @posts = @topic.posts.find(:all, :order => 'created_at desc', :limit => 25)
        render :action => 'show.rxml', :layout => false
      end
    end
  end
  
  def new
    @referent = find_referent
    @topic = Topic.new
    @topic.referent = @referent
    @topic.collection = @referent.collection if @referent.has_collection?
    respond_to do |format|
      format.html { }
      format.js { render :action => 'inline', :layout => false }
    end
  end
  
  def inline
  end
  
  def create
    @topic = Topic.new(params[:topic])
    @topic.referent = find_referent
    @topic.save!
    if @topic.save
      @topic.tags << Tag.from_list(params[:tag_list])
      respond_to do |format|
        format.html { redirect_to :action => 'show', :id => @topic }
        format.js { render :layout => false } # topics/create.rhtml is a bare list item
        format.json { render :json => @topic.to_json }
      end
    else
      # or what?
      render :action => 'new'
    end
  end
  
  def update
    @topic.attributes = params[:topic]
    @topic.save!
    respond_to do |format|
      format.html { redirect_to_referent }
    end
  end
  
  protected
  
    def find_referent
      logger.warn(Spoke::Config.discussed_models.inspect)
      ref = Spoke::Config.discussed_models.find{ |k| !params[("#{k.to_s}_id").intern].nil? }
      logger.warn("ref is #{ref.to_s._as_class}")
      @referent = ref ? ref.to_s._as_class.find(params[(ref.to_s.underscore + "_id").intern]) : nil
    end

end
