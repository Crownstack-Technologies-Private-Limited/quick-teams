require "test_helper"

class PwnedPasswordTest < ActiveSupport::TestCase
  def sign_up_form(password)
    SignUpForm.new.tap do |form|
      form.assign_attributes(first_name: "Ada", last_name: "Lovelace", email: "ada@acme.example", company: "Acme",
                             new_password: password, new_password_confirmation: password)
    end
  end

  test "sign-up rejects a password that appears in a breach" do
    Pwned::Password.any_instance.stubs(:fetch_pwned_count).returns(42)

    form = sign_up_form("Sup3r-secret!")

    assert_not form.valid?
    assert form.errors.added?(:new_password, :not_pwned, count: 42)
  end

  test "sign-up accepts a password that has not been breached" do
    assert sign_up_form("Sup3r-secret!").valid?
  end

  test "a failing breach lookup does not block the user" do
    Pwned::Password.any_instance.stubs(:fetch_pwned_count).raises(Pwned::TimeoutError, "timeout")

    assert sign_up_form("Sup3r-secret!").valid?
  end

  test "changing a password also checks for breaches" do
    Pwned::Password.any_instance.stubs(:fetch_pwned_count).returns(1)
    form = ChangePasswordForm.new(users(:regular))
    form.new_password = form.new_password_confirmation = "Sup3r-secret!"

    form.valid?
    assert form.errors.added?(:new_password, :not_pwned, count: 1)
  end
end
