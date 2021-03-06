class PostsController < ApplicationController

  before_filter :find_topic
  before_filter :find_post, :only => [:edit, :update, :destroy]
  before_filter :build_post, :only => [:new, :preview, :create]

  def show
    respond_to do |format|
      format.html { redirect_to topic_path(@post.topic_id) }
      format.xml  { render :xml => @post.to_xml }
    end
  end
  
  def new
    @post.created_by = current_user
    @post.created_at = Time.now()
    respond_to do |format|
      format.html  { render :template => 'posts/new' }
      format.js { render :template => 'posts/new', :layout => false }
      format.json { render :json => @post.to_json }
    end
  end

  def preview
    @post.created_by = current_user
    @post.created_at = Time.now()
    respond_to do |format|
      format.html { render :template => 'posts/preview' }
      format.js { render :layout => false, :template => 'posts/preview' }
      format.json { render :json => @post.to_json }
    end
  end

  def create
    if (params[:dispatch] == 'revise' || !@post.valid?)
      new
    elsif (params[:dispatch] == 'preview')
      preview
    else
      @post.save!
      respond_to do |format|
        format.html { redirect_to topic_path(:id => params[:topic_id], :anchor => @post.dom_id, :page => params[:page] || '1') }
        format.js { render :layout => false }
        format.json { render :json => @post.to_json }
      end
    end
  rescue ActiveRecord::RecordInvalid
    flash[:error] = 'Please post something!'
    redirect_to :action => 'new'
  end
  
  def edit
    respond_to do |format| 
      format.html { }
      format.js { render :layout => false }
    end
  end
  
  def update
    @post.attributes = params[:post]
    @post.save!
  rescue ActiveRecord::RecordInvalid
    flash[:error] = 'An error occurred'
    redirect_to :action => 'edit'
  end

  def destroy
    @post.destroy
    flash[:notice] = "One post attached to #{CGI::escapeHTML(@post.topic.title)} was deleted."
    respond_to do |format|
      format.html { redirect_to topic_path(:id => params[:topic_id], :page => params[:page]) unless performed? }
      format.js { render :nothing => true }
    end
  end

  protected
    def authorized?
      action_name == 'create' || @post.editable_by?(current_user)
    end
    
    def find_topic 
      @topic = Topic.find(params[:topic_id])
    end
    
    def find_post
      @post = Post.find(params[:id]) || raise(ActiveRecord::RecordNotFound)
    end
    
    def build_post
      @post = @topic.posts.build(params[:post])
    end
    
end
