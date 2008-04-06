class PostsController < ApplicationController

  def index
    conditions = []
    [:user_id, :topic_id].each { |attr| conditions << Post.send(:sanitize_sql, ["posts.#{attr} = ?", params[attr]]) if params[attr] }
    conditions = conditions.any? ? conditions.collect { |c| "(#{c})" }.join(' AND ') : nil
    @post_pages, @posts = paginate(:posts, @@query_options.merge(:conditions => conditions))
    @users = User.find(:all, :select => 'distinct *', :conditions => ['id in (?)', @posts.collect(&:user_id).uniq]).index_by(&:id)
    render_posts_or_xml
  end

  def show
    respond_to do |format|
      format.html { redirect_to topic_path(@post.topic_id) }
      format.xml  { render :xml => @post.to_xml }
    end
  end

  def new
    @topic = Topic.find(params[:topic_id])
    @post = @topic.posts.build
    respond_to do |format|
      format.html { redirect_to topic_path(@topic.id) }
      format.js { render :action => 'inline', :layout => false }
    end
  end
  
  def inline
  end

  def preview
    @topic = Topic.find(params[:topic_id])
    @post = @topic.posts.build(params[:post])
    @post.creator = current_user
    @post.created_at = Time.now()
    respond_to do |format|
      format.js { render :layout => false }
      format.html
    end
  end
    
  def create
    @topic = Topic.find(params[:topic_id])
    @post  = @topic.posts.build(params[:post])
    @post.save!
    respond_to do |format|
      format.js { render :layout => false }
      format.json { render :json => @post.to_json }
      format.html { redirect_to topic_path(:id => params[:topic_id], :anchor => @post.dom_id, :page => params[:page] || '1') }
      format.xml { head :created, :location => formatted_post_url(:topic_id => params[:topic_id], :id => @post, :format => :xml) }
    end
  rescue ActiveRecord::RecordInvalid
    flash[:bad_reply] = 'Please post something!'
    respond_to do |format|
      format.html { redirect_to topic_path(:id => params[:topic_id], :anchor => 'reply-form', :page => params[:page] || '1') }
      format.js { render :action => 'inline', :layout => false }
      format.xml { render :xml => @post.errors.to_xml, :status => 400 }
    end
  end
  
  def edit
    @topic = Topic.find(params[:topic_id])
    @post = @topic.posts.find(params[:id])
    respond_to do |format| 
      format.html { }
      format.js { render :action => 'inline', :layout => false }
    end
  end
  
  def update
    @topic = Topic.find(params[:topic_id])
    @post = @topic.posts.find(params[:id])
    @post.attributes = params[:post]
    @post.save!
  rescue ActiveRecord::RecordInvalid
    flash[:bad_reply] = 'An error occurred'
    respond_to do |format|
      format.html { redirect_to topic_path(:id => params[:topic_id], :anchor => @post.dom_id, :page => params[:page] || '1') }
      format.js { render :action => 'inline', :layout => false }
      format.xml { head 200 }
    end
  end

  def destroy
    @post.destroy
    flash[:notice] = "One post attached to #{CGI::escapeHTML(@post.topic.title)} was deleted."
    # check for posts_count == 1 because its cached and counting the currently deleted post
    respond_to do |format|
      format.html { redirect_to topic_path(:id => params[:topic_id], :page => params[:page]) unless performed? }
      format.js { render :nothing => true }
      format.xml { head 200 }
    end
  end

  protected
    def authorized?
      action_name == 'create' || @post.editable_by?(current_user)
    end
    
    def find_post
      @post = Post.find(params[:id]) || raise(ActiveRecord::RecordNotFound)
    end
    
    def render_posts_or_xml(template_name = action_name)
      respond_to do |format|
        format.html { render :action => "#{template_name}.rhtml" }
        format.rss  { render :action => "#{template_name}.rxml", :layout => false }
        format.xml  { render :xml => @posts.to_xml }
      end
    end
end
