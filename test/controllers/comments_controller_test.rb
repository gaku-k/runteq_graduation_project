require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @post = posts(:one)
    @comment = Comment.create!(
      user: @user,
      body: "test",
      commentable: @post
    )
    sign_in @user
  end

  test "should create comment" do
    post post_comments_path(@post), params: {
      comment: { body: "テストコメント" }
    }
    assert_response :redirect
  end

  test "should destroy comment" do
    delete comment_path(@comment)
    assert_response :redirect
  end
end
