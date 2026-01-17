require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @post = Post.create!(user: @user. body: "test")
    @comment = comments(:one)
    sign_in @user
  end

  test "should get create" do
    post post_comments_path(@post), params: {
      comment: { body: "テストコメント" }
    }
    assert_response :redirect
  end

  test "should get destroy" do
    delete comment_path(@comment)
    assert_response :redirect
  end
end
