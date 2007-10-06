require File.dirname(__FILE__) + '/../test_helper'
require 'surveys_controller'

# Re-raise errors caught by the controller.
class SurveysController; def rescue_action(e) raise e end; end

class SurveysControllerTest < Test::Unit::TestCase
  fixtures :surveys

  def setup
    @controller = SurveysController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = surveys(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:surveys)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:survey)
    assert assigns(:survey).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:survey)
  end

  def test_create
    num_surveys = Survey.count

    post :create, :survey => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_surveys + 1, Survey.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:survey)
    assert assigns(:survey).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Survey.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Survey.find(@first_id)
    }
  end
end
