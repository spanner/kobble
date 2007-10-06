class SurveysController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @survey_pages, @surveys = paginate :surveys, :per_page => 10
  end

  def show
    @survey = Survey.find(params[:id])
  end

  def new
    @survey = Survey.new
  end

  def create
    @survey = Survey.new(params[:survey])
    if @survey.save
      flash[:notice] = 'Survey was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @survey = Survey.find(params[:id])
  end

  def update
    @survey = Survey.find(params[:id])
    if @survey.update_attributes(params[:survey])
      flash[:notice] = 'Survey was successfully updated.'
      redirect_to :action => 'show', :id => @survey
    else
      render :action => 'edit'
    end
  end

  def destroy
    Survey.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
