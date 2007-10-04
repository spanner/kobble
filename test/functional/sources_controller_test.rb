require File.dirname(__FILE__) + '/../test_helper'
require 'sources_controller'

# Re-raise errors caught by the controller.
class SourcesController; def rescue_action(e) raise e end; end

class SourcesControllerTest < Test::Unit::TestCase
  fixtures :sources

  def setup
    @controller = SourcesController.new
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

    assert_not_nil assigns(:sources)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:source)
    assert assigns(:source).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:source)
  end

  def test_create
    num_sources = Source.count

    post :create, :source => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_sources + 1, Source.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:source)
    assert assigns(:source).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Source.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Source.find(1)
    }
  end
end
