require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "an invalid HTML sign-up re-renders the form instead of raising UnknownFormat" do
    post "/users", params: { user: { first_name: "", last_name: "", email: "", company: "", new_password: "", new_password_confirmation: "" } },
                   env: { "REQUEST_PATH" => "/users" }

    assert_response :unprocessable_content
    assert_select "form[action='/users']"
  end
end
