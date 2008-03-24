class TopicsController < ApplicationController
  before_filter :activation_required
  
  def list
    page = params[:page] || 1
    perpage = params[:perpage] || self.list_length
    sort_options = request.parameters[:controller].to_s._as_class.sort_options
    sort = sort_options[params[:sort]] || sort_options[request.parameters[:controller].to_s._as_class.default_sort]

    @list = Topic.paginate :conditions => conditions, :order => sort, :page => page, :per_page => perpage
    respond_to do |format|
      format.html { render :template => 'shared/mainlist' }
      format.js { render :template => 'shared/mainlist', :layout => false }
    end
  end

  def show
    @topic = Topic.find(params[:id])
    page = params[:page] || 1
    perpage = params[:perpage] || 25
    respond_to do |format|
      format.html do
        @topic.body = @topic.posts.first.body
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
    @topic = Topic.new(:referent => @referent)
  end
  
  def create
    # this is icky - move the topic/first post workings into the topic model?
    Topic.transaction do
      @topic = Topic.new(params[:topic])
      @topic.referent = find_referent
      @post = @topic.posts.build(params[:topic])
      @post.topic = @topic
      @topic.body = @post.body      # in case save fails and we go back to the form
      @topic.save! if @post.valid?  # we only save topic if post is valid so if there was an error in the view then the topic object will still be a new record
      @post.save! 
    end    
    respond_to do |format|
      format.html { redirect_to :action => 'show', :id => @topic }
      format.xml  { head :created, :location => formatted_topic_url(:id => @topic, :format => :xml) }
    end
  end
  
  def update
    @topic.attributes = params[:topic]
    @topic.save!
    respond_to do |format|
      format.html { redirect_to_referent }
      format.xml  { head 200 }
    end
  end
  
  protected
  
    def find_referent
      referent_class = Spoke::Config.discussed_models.find{ |k| !params[(k.to_s.underscore + "_id").intern].nil? }
      @referent = referent_class ? referent_class.find(params[(referent_class.to_s.underscore + "_id").intern]) : nil
    end

end
