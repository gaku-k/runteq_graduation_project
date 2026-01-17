require "test_helper"

class LikePostsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @post = Post.create!(user: @user. body: "test")
    sign_in @user
  end

  test "should create like" do
    post post_like_posts_path(@post)
    assert_response :redirect
  end

  test "should destroy like" do
    delete post_like_posts_path(@post)
    assert_response :redirect
  end
end
