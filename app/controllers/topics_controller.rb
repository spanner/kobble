class TopicsController < ApplicationController

  before_filter :find_referent
  before_filter :find_topic, :except => [:new, :preview, :create, :index]
  before_filter :build_topic, :only => [:new, :preview, :create]

  def views
    'list'
  end
  
  def list
    @topics = paged_list
    @klass = Topic
  end

  def show
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
    @topic.referent = find_referent
    respond_to do |format|
      format.html { render :action => 'new' }
      format.js { render :action => 'new', :layout => 'inline' }
    end
  end
    
  def preview
    logger.warn('@@@@ topic preview!')
    @topic.creator = current_user
    @topic.created_at = Time.now()
    if (@topic.valid?)
      respond_to do |format|
        format.html { render :action => 'preview' }
        format.js { render :action => 'preview', :layout => 'inline' }
        format.json { render :json => @topic.to_json }
      end
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js { render :action => 'new', :layout => 'inline' }
        format.json { render :json => {:errors => @topic.errors}.to_json }
      end
    end
  end

  def create
    if (params[:dispatch] == 'revise' || !@topic.valid?)
      new
    elsif (params[:dispatch] == 'preview')
      preview
    else
      @topic.save!
      @topic.add_monitors(User.find_by_id(params[:monitors])) if params[:monitors]
      respond_to do |format|
        format.html { redirect_to :action => 'show', :id => @topic }
        format.js { render :layout => false } # topics/create.rhtml is a bare list item
        format.json { render :json => @topic.to_json }
      end
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.html { render :action => 'new' }
      format.js { render :action => 'new', :layout => 'inline' }
      format.json { render :json => {:errors => @topic.errors}.to_json }
    end
  end

  def update
    @topic.attributes = params[:topic]
    @topic.save!
    respond_to do |format|
      format.html { redirect_to url_for(@topic) }
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.html { render :action => 'edit' }
      format.js { render :action => 'edit', :layout => 'inline' }
      format.json { render :json => {:errors => @topic.errors}.to_json }
    end
  end
  
  protected
  
    def find_referent
      ref = Kobble.discussed_models.find{ |k| !params[("#{k.to_s}_id").intern].nil? }
      @referent = ref ? ref.to_s.as_class.find(params[(ref.to_s.underscore + "_id").intern]) : nil
    end

    def find_topic
      if (@referent)
        @topic = @referent.topics.find(params[:id])
      else
        @topic = Topic.find(params[:id])
        @referent = @topic.referent           #naughty
      end
    end

    def build_topic
      @topic = @referent.topics.build(params[:topic])
      @topic.collection = @referent.collection if @referent.has_collection?
    end
  
end
