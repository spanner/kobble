require File.dirname(__FILE__) + '/../test_helper'
require 'clusters_controller'

# Re-raise errors caught by the controller.
class ClustersController; def rescue_action(e) raise e end; end

class ClustersControllerTest < Test::Unit::TestCase
  fixtures :clusters

  def setup
    @controller = ClustersController.new
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

    assert_not_nil assigns(:clusters)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:cluster)
    assert assigns(:cluster).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:cluster)
  end

  def test_create
    num_clusters = Cluster.count

    post :create, :cluster => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_clusters + 1, Cluster.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:cluster)
    assert assigns(:cluster).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Cluster.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Cluster.find(1)
    }
  end
end
