require File.dirname(__FILE__) + '/../test_helper'
require 'bill_versions_controller'

# Re-raise errors caught by the controller.
class BillVersionsController; def rescue_action(e) raise e end; end

class BillVersionsControllerTest < Test::Unit::TestCase
  fixtures :bill_versions

  def setup
    @controller = BillVersionsController.new
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

    assert_not_nil assigns(:bill_versions)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:bill_version)
    assert assigns(:bill_version).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:bill_version)
  end

  def test_create
    num_bill_versions = BillVersion.count

    post :create, :bill_version => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_bill_versions + 1, BillVersion.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:bill_version)
    assert assigns(:bill_version).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil BillVersion.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      BillVersion.find(1)
    }
  end
end
