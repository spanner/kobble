class PostsController < ApplicationController
  before_filter :find_post, :except => [:index, :new, :create, :monitored, :search, :preview]
  before_filter :editor_required, :only => [:edit, :update, :destroy]

  @@query_options = { :per_page => 25, :select => 'posts.*, topics.title as topic_title', :joins => 'inner join topics on posts.topic_id = topics.id', :order => 'posts.created_at desc' }

  def index
    conditions = []
    [:user_id, :topic_id].each { |attr| conditions << Post.send(:sanitize_sql, ["posts.#{attr} = ?", params[attr]]) if params[attr] }
    conditions = conditions.any? ? conditions.collect { |c| "(#{c})" }.join(' AND ') : nil
    @post_pages, @posts = paginate(:posts, @@query_options.merge(:conditions => conditions))
    @users = User.find(:all, :select => 'distinct *', :conditions => ['id in (?)', @posts.collect(&:user_id).uniq]).index_by(&:id)
    render_posts_or_xml
  end

  def search
    conditions = params[:q].blank? ? nil : Post.send(:sanitize_sql, ['LOWER(posts.body) LIKE ?', "%#{params[:q]}%"])
    @post_pages, @posts = paginate(:posts, @@query_options.merge(:conditions => conditions))
    @users = User.find(:all, :select => 'distinct *', :conditions => ['id in (?)', @posts.collect(&:user_id).uniq]).index_by(&:id)
    render_posts_or_xml :index
  end

  def monitored
    @user = User.find params[:user_id]
    options = @@query_options.merge(:conditions => ['monitorships.user_id = ? and posts.user_id != ? and monitorships.active = ?', params[:user_id], @user.id, true])
    options[:joins] += ' inner join monitorships on monitorships.topic_id = topics.id'
    @post_pages, @posts = paginate(:posts, options)
    render_posts_or_xml
  end

  def show
    respond_to do |format|
      format.html { redirect_to topic_path(@post.topic_id) }
      format.xml  { render :xml => @post.to_xml }
    end
  end

  def new
    @post = @topic.posts.build
    respond_to do |format|
      format.html { redirect_to topic_path(@topic.id) }
      format.js { render :template => 'posts/newinplace', :layout => false }
    end
  end

  def preview
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
      format.js do
        render :layout => false
      end
      format.html do
        redirect_to topic_path(:id => params[:topic_id], :anchor => @post.dom_id, :page => params[:page] || '1')
      end
      format.xml { head :created, :location => formatted_post_url(:topic_id => params[:topic_id], :id => @post, :format => :xml) }
    end
  rescue ActiveRecord::RecordInvalid
    flash[:bad_reply] = 'Please post something!'[:post_something_message]
    respond_to do |format|
      format.html do
        redirect_to topic_path(:id => params[:topic_id], :anchor => 'reply-form', :page => params[:page] || '1')
      end
      format.xml { render :xml => @post.errors.to_xml, :status => 400 }
    end
  end
  
  def edit
    respond_to do |format| 
      format.html
      format.js { render :template => 'posts/editinplace', :layout => false }
    end
  end
  
  def update
    @post.attributes = params[:post]
    @post.save!
  rescue ActiveRecord::RecordInvalid
    flash[:bad_reply] = 'An error occurred'[:error_occured_message]
  ensure
    respond_to do |format|
      format.html do
        redirect_to topic_path(:id => params[:topic_id], :anchor => @post.dom_id, :page => params[:page] || '1')
      end
      format.js { render :layout => false }
      format.xml { head 200 }
    end
  end

  def destroy
    @post.destroy
    flash[:notice] = "One post attached to #{CGI::escapeHTML(@post.topic.title)} was deleted."
    # check for posts_count == 1 because its cached and counting the currently deleted post
    @post.topic.destroy and redirect_to :controller => @post.topic.subject_path if @post.topic.posts_count == 1
    respond_to do |format|
      format.html do
        redirect_to topic_path(:id => params[:topic_id], :page => params[:page]) unless performed?
      end
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
