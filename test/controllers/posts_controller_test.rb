require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get posts index" do
    get posts_url
    assert_response :success
  end

  test "should show post" do
    user = User.create!(
      name: "TestTraveler",
      email_address: "posttest@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post = Post.create!(
      title: "Beautiful Beach",
      body: "A wonderful trip to Shizuoka.",
      location: "Shizuoka, Japan",
      user: user
    )

    get post_url(post)
    assert_response :success
  end

  test "should create post when logged in" do
    user = User.create!(
      name: "CreateTestUser",
      email_address: "createtest@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post sessions_url, params: {
      email_address: user.email_address,
      password: "password123"
    }

    assert_redirected_to root_path

    assert_difference("Post.count", 1) do
      post posts_url, params: {
        post: {
          title: "My First Trip",
          body: "I visited a beautiful beach in Japan.",
          location: "Shizuoka, Japan"
        }
      }
    end
  end

  test "should not create post when not logged in" do
    assert_no_difference("Post.count") do
      post posts_url, params: {
        post: { title: "Unauthorized Post", body: "Guest should not create this post.", location: "Tokyo, Japan" }
      }
    end

    assert_redirected_to new_sessions_path
  end

  test "should update post when owner is logged in" do
    user = User.create!(
      name: "UpdateTestUser",
      email_address: "updatetest@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post_record = Post.create!(
      title: "Old Title",
      body: "Old travel story.",
      location: "Tokyo, Japan",
      user: user
    )

    post sessions_url, params: {
      email_address: user.email_address,
      password: "password123"
    }

    patch post_url(post_record), params: {
      post: {
        title: "Updated Title",
        body: "Updated travel story.",
        location: "Kyoto, Japan"
      }
    }

    assert_redirected_to post_url(post_record)

    post_record.reload

    assert_equal "Updated Title", post_record.title
    assert_equal "Updated travel story.", post_record.body
    assert_equal "Kyoto, Japan", post_record.location
  end

  test "should not update post when user is not owner" do
    owner = User.create!(
      name: "PostOwner",
      email_address: "owner@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    other_user = User.create!(
      name: "OtherUser",
      email_address: "other@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post_record = Post.create!(
      title: "Original Title",
      body: "Original travel story.",
      location: "Tokyo, Japan",
      user: owner
    )

    post sessions_url, params: {
      email_address: other_user.email_address,
      password: "password123"
    }

    patch post_url(post_record), params: {
      post: {
        title: "Hacked Title",
        body: "Changed by another user.",
        location: "Osaka, Japan"
      }
    }

    post_record.reload

    assert_equal "Original Title", post_record.title
    assert_equal "Original travel story.", post_record.body
    assert_equal "Tokyo, Japan", post_record.location
  end

  test "should delete post when owner is logged in" do
    user = User.create!(
      name: "DeleteTestUser",
      email_address: "deletetest@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post_record = Post.create!(
      title: "Post To Delete",
      body: "This post will be deleted.",
      location: "Tokyo, Japan",
      user: user
    )

    post sessions_url, params: {
      email_address: user.email_address,
      password: "password123"
    }

    assert_redirected_to root_path

    assert_difference("Post.count", -1) do
      delete post_url(post_record)
    end

    assert_redirected_to posts_path

    assert_nil Post.find_by(id: post_record.id)
  end

  test "should not delete post when user is not owner" do
    owner = User.create!(
      name: "DeleteOwner",
      email_address: "deleteowner@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    other_user = User.create!(
      name: "DeleteOtherUser",
      email_address: "deleteother@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post_record = Post.create!(
      title: "Owner's Travel Story",
      body: "This post belongs to the owner.",
      location: "Kyoto, Japan",
      user: owner
    )

    post sessions_url, params: {
      email_address: other_user.email_address,
      password: "password123"
    }

    assert_redirected_to root_path

    assert_no_difference("Post.count") do
      delete post_url(post_record)
    end

    assert Post.exists?(post_record.id)
  end
end
