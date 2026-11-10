require "test_helper"

class LikesControllerTest < ActionDispatch::IntegrationTest
  test "should create like when logged in" do
    user = User.create!(
      name: "LikeTestUser",
      email_address: "liketest@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post_record = Post.create!(
      title: "Beautiful Beach",
      body: "A wonderful trip to Shizuoka.",
      location: "Shizuoka, Japan",
      user: user
    )

    post sessions_url, params: {
      email_address: user.email_address,
      password: "password123"
    }

    assert_difference("Like.count", 1) do
      post post_like_url(post_record)
    end

    assert_redirected_to post_url(post_record)
    assert Like.exists?(user: user, post: post_record)
    end

  test "should not create duplicate likes" do
    user = User.create!(
      name: "DuplicateLikeUser",
      email_address: "duplicatelike@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post_record = Post.create!(
      title: "Tokyo Adventure",
      body: "My wonderful trip to Tokyo.",
      location: "Tokyo, Japan",
      user: user
    )

    post sessions_url, params: {
      email_address: user.email_address,
      password: "password123"
    }

    assert_difference("Like.count", 1) do
      post post_like_url(post_record)
    end

    assert_no_difference("Like.count") do
      post post_like_url(post_record)
    end

    assert_equal 1, post_record.likes.count
    end

  test "should unlike post when logged in" do
    user = User.create!(
      name: "UnlikeTestUser",
      email_address: "unliketest@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post_record = Post.create!(
      title: "Kyoto Adventure",
      body: "A wonderful trip to Kyoto.",
      location: "Kyoto, Japan",
      user: user
    )

    Like.create!(user: user, post: post_record)

    post sessions_url, params: {
      email_address: user.email_address,
      password: "password123"
    }

    assert_difference("Like.count", -1) do
      delete post_like_url(post_record)
    end

    assert_redirected_to post_url(post_record)

    assert_not Like.exists?(user: user, post: post_record)
    end

  test "guest should not be able to like post" do
    user = User.create!(
      name: "GuestLikeTestUser",
      email_address: "guestliketest@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post_record = Post.create!(
      title: "Osaka Adventure",
      body: "A wonderful trip to Osaka.",
      location: "Osaka, Japan",
      user: user
    )

    assert_no_difference("Like.count") do
      post post_like_url(post_record)
    end

    assert_redirected_to new_sessions_path
    end

  test "guest should not be able to unlike post" do
    user = User.create!(
      name: "GuestUnlikeTestUser",
      email_address: "guestunliketest@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post_record = Post.create!(
      title: "Hokkaido Adventure",
      body: "A wonderful trip to Hokkaido.",
      location: "Hokkaido, Japan",
      user: user
    )

    Like.create!(user: user, post: post_record)

    assert_no_difference("Like.count") do
      delete post_like_url(post_record)
    end

    assert_redirected_to new_sessions_path

    assert Like.exists?(user: user, post: post_record)
    end
end
