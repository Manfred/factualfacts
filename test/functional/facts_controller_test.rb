require File.dirname(__FILE__) + '/../test_helper'

class FactsControllerTest < ActionController::TestCase
  test "index should show facts" do
    get :index
    assert_response :ok
    assert_template 'facts/index'
    assert_select 'p.fact'
  end
  
  test "new should show a new fact form" do
    get :new
    assert_response :ok
    assert_template 'facts/new'
    assert_select 'form'
  end
  
  test "should create new facts" do
    post :create, 'fact' => { 'body' => 'Nothing is ever certain.' }
    assert_redirected_to root_url
  end
  
  test "shows validation errors on incomplete create" do
    post :create, 'fact' => {}
    assert_response :ok
    assert_template 'facts/new'
    assert_select 'form'
  end
end
