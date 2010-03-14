require File.dirname(__FILE__) + '/../test_helper'
require 'politicians_controller'

# Re-raise errors caught by the controller.
class PoliticiansController; def rescue_action(e) raise e end; end

class PoliticiansControllerTest < Test::Unit::TestCase
  fixtures :politicians

  def setup
    @controller = PoliticiansController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = politicians(:first).id
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

    assert_not_nil assigns(:politicians)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:politician)
    assert assigns(:politician).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:politician)
  end

  def test_create
    num_politicians = Politician.count

    post :create, :politician => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_politicians + 1, Politician.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:politician)
    assert assigns(:politician).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Politician.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Politician.find(@first_id)
    }
  end
end
