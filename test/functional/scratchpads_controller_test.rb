require File.dirname(__FILE__) + '/../test_helper'
require 'scratchpads_controller'

# Re-raise errors caught by the controller.
class ScratchpadsController; def rescue_action(e) raise e end; end

class ScratchpadsControllerTest < Test::Unit::TestCase
  fixtures :scratchpads

  def setup
    @controller = ScratchpadsController.new
    request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
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

    assert_not_nil assigns(:scratchpads)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:scratchpad)
    assert assigns(:scratchpad).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:scratchpad)
  end

  def test_create
    num_scratchpads = Scratchpad.count

    post :create, :scratchpad => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_scratchpads + 1, Scratchpad.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:scratchpad)
    assert assigns(:scratchpad).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Scratchpad.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Scratchpad.find(1)
    }
  end
end
