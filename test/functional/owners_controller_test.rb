require File.dirname(__FILE__) + '/../test_helper'
require 'owners_controller'

# Re-raise errors caught by the controller.
class OwnersController; def rescue_action(e) raise e end; end

class OwnersControllerTest < Test::Unit::TestCase
  fixtures :owners

  def setup
    @controller = OwnersController.new
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

    assert_not_nil assigns(:owners)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:owner)
    assert assigns(:owner).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:owner)
  end

  def test_create
    num_owners = Owner.count

    post :create, :owner => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_owners + 1, Owner.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:owner)
    assert assigns(:owner).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Owner.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Owner.find(1)
    }
  end
end
