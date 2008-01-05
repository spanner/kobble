require File.dirname(__FILE__) + '/../test_helper'
require 'blogentries_controller'

# Re-raise errors caught by the controller.
class BlogentriesController; def rescue_action(e) raise e end; end

class BlogentriesControllerTest < Test::Unit::TestCase
  fixtures :blogentries

  def setup
    @controller = BlogentriesController.new
    request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = blogentries(:first).id
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

    assert_not_nil assigns(:blogentries)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:blogentry)
    assert assigns(:blogentry).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:blogentry)
  end

  def test_create
    num_blogentries = Blogentry.count

    post :create, :blogentry => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_blogentries + 1, Blogentry.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:blogentry)
    assert assigns(:blogentry).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Blogentry.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Blogentry.find(@first_id)
    }
  end
end
