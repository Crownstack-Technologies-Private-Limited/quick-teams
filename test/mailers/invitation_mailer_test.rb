require "test_helper"

class InvitationMailerTest < ActionMailer::TestCase
  setup do
    Rails.application.reload_routes_unless_loaded
    @account = accounts(:crownstack)
    ActsAsTenant.current_tenant = @account
  end

  test "both parts link to the invitation under the account's path" do
    invitee = User.invite!({ email: "new.hire@crownstack.com", first_name: "New", last_name: "Hire", account: @account,
                             role: roles(:senior), job: jobs(:ios), discipline: disciplines(:engineering) }, users(:regular))
    mail = ActionMailer::Base.deliveries.last

    assert_equal [invitee.email], mail.to
    expected = %r{/#{@account.id}/users/invitation/accept\?invitation_token=}
    assert_match expected, mail.html_part.body.decoded
    assert_match expected, mail.text_part.body.decoded
  end
end
