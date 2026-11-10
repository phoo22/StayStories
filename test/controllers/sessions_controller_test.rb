require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_sessions_url
    assert_response :success
  end

  test "should login with valid credentials" do
    user = User.create!(
      name: "LoginTestUser",
      email_address: "logintest@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post sessions_url, params: {
      email_address: user.email_address,
      password: "password123"
    }

    assert_redirected_to root_path
    assert_equal "Signed in successfully!", flash[:notice]

    follow_redirect!
    assert_response :success
  end

  test "should not login with invalid password" do
    user = User.create!(
      name: "InvalidLoginUser",
      email_address: "invalidlogin@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post sessions_url, params: {
      email_address: user.email_address,
      password: "wrongpassword"
    }

    assert_response :unprocessable_entity
    assert_select ".alert", text: /Invalid email or password/
  end

  test "should logout successfully" do
    user = User.create!(
      name: "LogoutTestUser",
      email_address: "logouttest@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post sessions_url, params: {
      email_address: user.email_address,
      password: "password123"
    }

    assert_redirected_to root_path

    delete sessions_url

    assert_redirected_to root_path
    assert_equal "Signed out successfully!", flash[:notice]

    get new_post_url

    assert_redirected_to new_sessions_path
  end
end
