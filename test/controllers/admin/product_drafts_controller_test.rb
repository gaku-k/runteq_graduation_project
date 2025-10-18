require "test_helper"

class Admin::ProductDraftsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_product_drafts_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_product_drafts_show_url
    assert_response :success
  end
end
