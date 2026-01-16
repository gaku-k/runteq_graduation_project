require "test_helper"

class Admin::ProductDraftsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
  end

  test "should get index" do
    get admin_product_drafts_path
    assert_response :success
  end

  test "should get show" do
    get admin_product_draft_path(draft)
    assert_response :success
  end
end
