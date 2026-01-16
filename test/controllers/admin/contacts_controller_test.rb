require "test_helper"

class Admin::ContactsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @contact = contacts(:one)
    sign_in users(:admin)
  end

  test "should get index" do
    get admin_contacts_path
    assert_response :success
  end

  test "should get show" do
    get admin_contact_path(@contact)
    assert_response :success
  end
end
