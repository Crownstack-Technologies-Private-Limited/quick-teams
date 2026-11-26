require "test_helper"

class Purchase::CheckoutsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
    @account = @user.account
    sign_in @user
  end

  test "creates a card-only subscription checkout session and redirects to Stripe" do
    session = Stripe::Checkout::Session.construct_from(id: "cs_test_123", url: "https://checkout.stripe.com/c/pay/cs_test_123")
    Stripe::Checkout::Session.expects(:create).with do |params, _opts|
      params[:mode] == "subscription" &&
        params[:allowed_payment_method_types] == ["card"] &&
        !params.key?(:payment_method_types) &&
        params[:customer] == pay_customers(:regular).processor_id &&
        params[:line_items] == [{ quantity: 1, price: "price_123" }] &&
        params[:cancel_url].start_with?("http://www.example.com/#{@account.id}/account/billing")
    end.returns(session)

    path = "/#{@account.id}/purchase/checkouts"
    post path, params: { price_id: "price_123" }, env: { "REQUEST_PATH" => path }

    assert_redirected_to "https://checkout.stripe.com/c/pay/cs_test_123"
  end
end
