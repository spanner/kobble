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
    @topic = Topic.new
    @topic.referent = find_referent
    respond_to do |format|
      format.html { }
      format.js { render :layout => 'inline' }
    end
  end
    
  def create
    @topic = Topic.new(params[:topic])
    @topic.referent = find_referent
    if @topic.save
      @topic.add_monitors(User.find_by_id(params[:monitors])) if params[:monitors]
      respond_to do |format|
        format.html { redirect_to :action => 'show', :id => @topic }
        format.js { render :layout => false } # topics/create.rhtml is a bare list item
        format.json { render :json => @topic.to_json }
      end
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js { render :action => 'new', :layout => 'inline' }
        format.json { render :json => {:errors => @node.errors}.to_json }
      end
    end
  end
  
  def update
    @topic.attributes = params[:topic]
    @topic.save!
    respond_to do |format|
      format.html { redirect_to url_for(@topic) }
    end
  end
  
  protected
  
    def find_referent
      ref = Spoke::Associations.discussed_models.find{ |k| !params[("#{k.to_s}_id").intern].nil? }
      @referent = ref ? ref.to_s._as_class.find(params[(ref.to_s.underscore + "_id").intern]) : nil
    end

end
