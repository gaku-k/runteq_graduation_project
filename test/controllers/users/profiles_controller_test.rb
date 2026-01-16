require "test_helper"

class Users::ProfilesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "should get edit" do
    get edit_users_profile_path
    assert_response :success
  end

  test "should get update" do
    patch users_profile_path, params: {
      user: {
        name: "updated name"
      }
    }

    assert_response :redirect
  end
end
