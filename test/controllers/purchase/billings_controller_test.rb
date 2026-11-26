require "test_helper"

class Purchase::BillingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
    @account = accounts(:crownstack)
    sign_in @user
  end

  test "redirects to the Stripe billing portal" do
    portal = Struct.new(:url).new("https://billing.stripe.com/session/test_123")
    Pay::Stripe::Customer.any_instance.expects(:billing_portal)
      .with(return_url: "http://www.example.com/#{@account.id}/account/billing")
      .returns(portal)

    path = "/#{@account.id}/billings"
    post path, env: { "REQUEST_PATH" => path }

    assert_redirected_to "https://billing.stripe.com/session/test_123"
    assert_instance_of Pay::Stripe::Customer, @user.reload.payment_processor
  end
end
