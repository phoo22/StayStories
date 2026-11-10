require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should show user profile" do
    user = User.create!(
      name: "TestTraveler",
      email_address: "testtraveler@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    get user_url(user)

    assert_response :success
    assert_select "h2", text: user.name
  end

  test "should return not found for nonexistent user" do
    get user_url(99999)

    assert_redirected_to posts_path
    assert_equal "User not found.", flash[:alert]
  end
end
