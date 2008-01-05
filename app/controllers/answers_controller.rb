class AnswersController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def show
    @answer = Answer.find(params[:id])
  end

  def new
    @answer = Answer.new
  end

  def create
    @answer = Answer.new(params[:answer])
    
    if @answer.save
      flash[:notice] = 'Answer was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @answer = Answer.find(params[:id])
  end

  def update
    @answer = Answer.find(params[:id])
    if @answer.update_attributes(params[:answer])
      flash[:notice] = 'Answer was successfully updated.'
      redirect_to :action => 'show', :id => @answer
    else
      render :action => 'edit'
    end
  end

  def destroy
    Answer.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
