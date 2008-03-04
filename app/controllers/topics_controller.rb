class TopicsController < ApplicationController
  skip_before_filter :editor_required
  before_filter :activation_required
  
  def new
    @topic = Topic.new
    @topic.subject = params[:subject_type]._as_class.find( params[:subject_id] ) if params[:subject_type] && params[:subject_id]
  end
  
  def show
    @pagetitle = 'discussion'
    perpage = params[:perpage] || 25
    respond_to do |format|
      format.html do
        @topic.body = @topic.posts.first.body
        @page_title = @topic.title
        @monitoring = !Monitorship.count(:all, :conditions => ['user_id = ? and topic_id = ? and active = ?', current_user.id, @topic.id, true]).zero?
        @posts = Post.find(:all, 
          :include => :creator, 
          :conditions => ['posts.topic_id = ?', params[:id]], 
          :page => {:size => perpage, :sort => 'posts.created_at', :current => params[:page]})
        @post = Post.new
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
      @topic = Topic.new(params[:topic])
      @post = @topic.posts.build(params[:topic])
      @post.topic = @topic
      @topic.body = @post.body      # in case save fails and we go back to the form
      @topic.save! if @post.valid?  # we only save topic if post is valid so if there was an error in the view then the topic object will be a new record
      @post.save! 
    end    
    respond_to do |format|
      format.html { redirect_to_subject }
      format.xml  { head :created, :location => formatted_topic_url(:id => @topic, :format => :xml) }
    end
  end
  
  def update
    @topic.attributes = params[:topic]
    @topic.save!
    respond_to do |format|
      format.html { redirect_to_subject }
      format.xml  { head 200 }
    end
  end
  
  def redirect_to_subject
    redirect_to @topic.subject_path
  end

end
