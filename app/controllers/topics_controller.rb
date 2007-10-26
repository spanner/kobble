class TopicsController < ApplicationController
  before_filter :find_forum_and_topic, :except => :index
  skip_before_filter :editor_required
#  before_filter :update_last_seen_at, :only => :show
  
  def index
    respond_to do |format|
      format.html { redirect_to forum_path(params[:forum_id]) }
      format.xml do
        @topics = Topic.find_all_by_forum_id(params[:forum_id], :order => 'sticky desc, replied_at desc', :limit => 25)
        render :xml => @topics.to_xml
      end
    end
  end

  def new
    @topic = Topic.new
    @topic.subject = params[:subject_type]._as_class.find(params[:subject_id]) if params[:subject_type] && params[:subject_id]
  end
  
  def show
    respond_to do |format|
      format.html do
        # see notes in application.rb on how this works
        update_last_seen_at
        # keep track of when we last viewed this topic for activity indicators
        (session[:topics] ||= {})[@topic.id] = Time.now.utc if logged_in?
        # authors of topics don't get counted towards total hits
        @topic.hit! unless logged_in? and @topic.created_by == current_user
        @post_pages, @posts = paginate(:posts, :per_page => 25, :order => 'posts.created_at', :include => :creator, :conditions => ['posts.topic_id = ?', params[:id]])
        @post   = Post.new
      end
      format.xml do
        render :xml => @topic.to_xml
      end
      format.rss do
        @posts = @topic.posts.find(:all, :order => 'created_at desc', :limit => 25)
        render :action => 'show.rxml', :layout => false
      end
    end
  end
  
  def create
    # this is icky - move the topic/first post workings into the topic model?
    Topic.transaction do
      @topic = @forum.topics.build(params[:topic])
      assign_protected
      @post = @topic.posts.build(params[:topic])
      @post.topic=@topic
      # only save topic if post is valid so in the view topic will be a new record if there was an error
      @topic.body = @post.body # incase save fails and we go back to the form
      @topic.save! if @post.valid?
      @post.save! 
    end    
    respond_to do |format|
      format.html { redirect_to topic_path(@forum, @topic) }
      format.xml  { head :created, :location => formatted_topic_url(:forum_id => @forum, :id => @topic, :format => :xml) }
    end
  end
  
  def update
    @topic.attributes = params[:topic]
    assign_protected
    @topic.save!
    respond_to do |format|
      format.html { redirect_to topic_path(@forum, @topic) }
      format.xml  { head 200 }
    end
  end
  
  def destroy
    @topic.destroy
    flash[:notice] = "Topic '{title}' was deleted."[:topic_deleted_message, CGI::escapeHTML(@topic.title)]
    respond_to do |format|
      format.html { redirect_to forum_path(@forum) }
      format.xml  { head 200 }
    end
  end
  
  protected
    def assign_protected
      # admins can move, sticky and lock topics
      return unless admin?
      @topic.sticky, @topic.locked = params[:topic][:sticky], params[:topic][:locked] 
      @topic.forum_id = params[:topic][:forum_id] if params[:topic][:forum_id]
    end
    
    def find_forum_and_topic
      @forum = Forum.find(params[:forum_id])
      @topic = @forum.topics.find(params[:id]) if params[:id]
    end
    
    def authorized?
      %w(new create).include?(action_name) || @topic.editable_by?(current_user)
    end
end
