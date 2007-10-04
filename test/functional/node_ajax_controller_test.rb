require File.dirname(__FILE__) + '/../test_helper'
require 'node_ajax_controller'

# Re-raise errors caught by the controller.
class NodeAjaxController; def rescue_action(e) raise e end; end

class NodeAjaxControllerTest < Test::Unit::TestCase
  fixtures :nodes

  def setup
    @controller = NodeAjaxController.new
    @request    = ActionController::TestRequest.new
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

    assert_not_nil assigns(:nodes)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:node)
    assert assigns(:node).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:node)
  end

  def test_create
    num_nodes = Node.count

    post :create, :node => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_nodes + 1, Node.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:node)
    assert assigns(:node).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Node.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Node.find(1)
    }
  end
end
