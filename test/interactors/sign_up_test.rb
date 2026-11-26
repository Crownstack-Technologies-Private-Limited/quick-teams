require "test_helper"

class SignUpTest < ActiveSupport::TestCase
  setup do
    # Devise mappings come from the routes, which Rails 8 loads lazily outside a request.
    Rails.application.reload_routes_unless_loaded
    ActsAsTenant.current_tenant = nil
    @account = Account.new(name: "Acme Widgets")
    @user = User.new(first_name: "Ada", last_name: "Lovelace", email: "ada@acme.example", password: "Sup3r-secret!", password_confirmation: "Sup3r-secret!")
  end

  test "creates the account, the owner and a fake-processor trial subscription" do
    user = SignUp.call(@account, @user).result

    assert user.persisted?
    assert_equal @account.reload.owner_id, user.id
    customer = user.payment_processor
    assert_instance_of Pay::FakeProcessor::Customer, customer
    subscription = customer.subscription
    assert_instance_of Pay::FakeProcessor::Subscription, subscription
    assert subscription.on_trial?
    assert_in_delta 14.days.from_now, subscription.trial_ends_at, 1.minute
  end

  test "keeps the new account when the trial cannot be created, and reports the error" do
    User.any_instance.stubs(:set_payment_processor).raises(StandardError, "boom")
    Rails.error.expects(:report).with { |error, **| error.message == "boom" }

    user = SignUp.call(@account, @user).result

    assert user.persisted?
  end

  test "returns an unsaved user when registration fails, and reports the error" do
    Discipline.stubs(:create!).raises(ActiveRecord::RecordInvalid)
    Rails.error.expects(:report).once

    user = SignUp.call(@account, @user).result

    assert_not user.persisted?
    assert_not @account.persisted?
  end
end
