class QuestionsController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @question_pages, @questions = paginate :questions, :per_page => 10
  end

  def show
    @question = Question.find(params[:id])
    @answer = Answer.new
    @answer.speaker = current_user
    @answer.question = @question
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
    @answer.body = params[:other] if @answer.body == 'other' || (@answer.body.size == 0 && params[:other])
    @answer.speaker = current_user
    @answer.question = @question
    if @answer.save
      flash[:notice] = 'Answer stored.'
      redirect_to :action => 'show', :id => @question
    end
  end
end
