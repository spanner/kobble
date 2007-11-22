class QuestionsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @question_pages, @questions = paginate :questions, :per_page => 10
  end

  def list
    @display = 'list'
    perpage = params[:perpage] || (@display == 'thumb') ? 100 : 40
    sort = case params[:sort]
      when "name"  then "name"
      when "date" then "created_at DESC"
      when "name_reverse" then "name DESC"
      when "date_reverse" then "created_at ASC"
      else "created_at DESC"
    end

    @questions = Question.find(:all, 
      :conditions => limit_to_active_collection, 
      :order => sort, 
      :page => {
        :size => perpage, 
        :current => params[:page]
      }
    )
  end

  def show
    @question = Question.find(params[:id])
  end

  def new
    @question = Question.new
  end

  def create
    @question = Question.new(params[:question])
    if @question.save
      @question.tags << tags_from_list(params[:tag_list])
      @question.user_groups = UserGroup.find( params[:user_groups] ) if params[:user_groups]
      flash[:notice] = 'Question was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @question = Question.find(params[:id])
  end

  def update
    @question = Question.find(params[:id])
    if @question.update_attributes(params[:question])
      @question.tags.clear
      @question.tags << tags_from_list(params[:tag_list])
      @question.user_groups = UserGroup.find( params[:user_groups] )
      flash[:notice] = 'Question was successfully updated.'
      redirect_to :action => 'show', :id => @question
    else
      render :action => 'edit'
    end
  end

  def destroy
    Question.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to :action => 'list' }
      format.js { render :nothing => true }
      format.xml { head 200 }
    end
  end
  
  def ask
    @question = Question.find(params[:id])
    @answer = Answer.new
    @answer.speaker = current_user
    @answer.question = @question
  end

  def answer
    @question = Question.find(params[:id])
    @answer = Answer.new(params[:answer])
    @answer.speaker = current_user
    @answer.question = @question
    if @answer.save
      flash[:notice] = 'Answer stored.'
      redirect_to :action => 'show', :id => @question
    end
  end
end
