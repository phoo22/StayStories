require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  test "should create comment when logged in" do
    user = User.create!(
      name: "CommentTestUser",
      email_address: "commenttest@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post_record = Post.create!(
      title: "Tokyo Adventure",
      body: "A wonderful trip to Tokyo.",
      location: "Tokyo, Japan",
      user: user
    )

    post sessions_url, params: {
      email_address: user.email_address,
      password: "password123"
    }

    assert_difference("Comment.count", 1) do
      post post_comments_url(post_record), params: {
        comment: {
          body: "Beautiful place!"
        }
      }
    end

    assert_redirected_to post_url(post_record)

    assert Comment.exists?(
      user: user,
      post: post_record,
      body: "Beautiful place!"
    )
  end

  test "should delete own comment when logged in" do
    user = User.create!(
      name: "DeleteCommentUser",
      email_address: "deletecomment@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post_record = Post.create!(
      title: "Kyoto Adventure",
      body: "A wonderful trip to Kyoto.",
      location: "Kyoto, Japan",
      user: user
    )

    comment = Comment.create!(
      body: "Amazing place!",
      user: user,
      post: post_record
    )

    post sessions_url, params: {
      email_address: user.email_address,
      password: "password123"
    }

    assert_difference("Comment.count", -1) do
      delete post_comment_url(post_record, comment)
    end

    assert_redirected_to post_url(post_record)

    assert_not Comment.exists?(id: comment.id)
  end

  test "should not delete another user's comment" do
    owner = User.create!(
      name: "CommentOwner",
      email_address: "commentowner@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    other_user = User.create!(
      name: "OtherCommentUser",
      email_address: "othercomment@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post_record = Post.create!(
      title: "Osaka Adventure",
      body: "A wonderful trip to Osaka.",
      location: "Osaka, Japan",
      user: owner
    )

    comment = Comment.create!(
      body: "I love Osaka!",
      user: owner,
      post: post_record
    )

    post sessions_url, params: {
      email_address: other_user.email_address,
      password: "password123"
    }

    assert_no_difference("Comment.count") do
      delete post_comment_url(post_record, comment)
    end

    assert_redirected_to post_url(post_record)

    assert Comment.exists?(id: comment.id)
  end

  test "guest should not be able to create comment" do
    user = User.create!(
      name: "GuestCommentTestUser",
      email_address: "guestcomment@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post_record = Post.create!(
      title: "Hokkaido Adventure",
      body: "A wonderful trip to Hokkaido.",
      location: "Hokkaido, Japan",
     user: user
    )

    assert_no_difference("Comment.count") do
      post post_comments_url(post_record), params: {
        comment: {body: "Beautiful place!"}
      }
    end

    assert_redirected_to new_sessions_path
  end

end
