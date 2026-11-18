require "test_helper"

class SubscriptionManagerTest < ActiveSupport::TestCase
  setup do
    @user = users(:actor)
    Pay::Customer.where(owner: @user).destroy_all
  end

  def fake_trial(ends_at)
    @user.set_payment_processor :fake_processor, allow_fake: true
    @user.payment_processor.subscribe(trial_ends_at: ends_at, ends_at: ends_at)
  end

  test "a user without a payment processor gets a Stripe customer and the subscribe page" do
    assert_nil @user.payment_processor

    assert_equal "subscribe", SubscriptionManager.new(@user).template
    assert_instance_of Pay::Stripe::Customer, @user.reload.payment_processor
  end

  test "a new account is on its trial" do
    fake_trial(14.days.from_now)

    manager = SubscriptionManager.new(@user)
    assert_equal "trial", manager.template
    assert_in_delta 14.days.from_now, manager.trial_ends_at, 1.minute
  end

  test "a trial that ran out is expired" do
    fake_trial(1.day.ago)

    assert_equal "expired", SubscriptionManager.new(@user).template
  end

  test "an active Stripe subscription is manageable" do
    assert_equal "manage", SubscriptionManager.new(users(:regular)).template
  end
end
