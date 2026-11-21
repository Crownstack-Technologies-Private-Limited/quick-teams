require "test_helper"

# The JSON endpoints behind the daily/weekly planner.
class JobCardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:crownstack)
    ActsAsTenant.current_tenant = @account
    @member = users(:member)
    @date = Date.current + 1.day
  end

  def account_request(method, path, account: @account, **options)
    full_path = "/#{account.id}#{path}"
    public_send(method, full_path, **options, as: :json, env: { "REQUEST_PATH" => full_path })
  end

  def card_params(user, **attributes)
    { job_card: { title: "Plan the sprint", description: "Backlog first", date: @date.iso8601, session: "morning",
                  slot_start: "2", slot_length: "3", color: "blue", user_id: user.id, card_id: "" }.merge(attributes) }
  end

  def create_card(user, **attributes)
    JobCard.create!({ user: user, title: "Existing card", date: @date, session: "afternoon", slot_start: 1, slot_length: 1 }.merge(attributes))
  end

  test "a member creates, reads, updates and deletes a card on their own planner" do
    sign_in @member

    assert_difference -> { @member.job_cards.count }, 1 do
      account_request :post, "/job_cards", params: card_params(@member)
    end
    assert_response :created
    card = @member.job_cards.last
    assert_equal({ "id" => card.id, "title" => "Plan the sprint", "slot_length" => 3, "message" => "Job card created successfully" }, response.parsed_body)
    assert_equal %w[blue morning], [card.color, card.session]

    account_request :get, "/job_cards/#{card.id}"
    assert_response :ok
    assert_equal "Backlog first", response.parsed_body["description"]

    account_request :patch, "/job_cards/#{card.id}", params: { job_card: { title: "Plan the release", color: "red", card_id: card.id.to_s } }
    assert_response :ok
    assert_equal %w[Plan\ the\ release red], card.reload.values_at(:title, :color)

    assert_difference -> { JobCard.count }, -1 do
      account_request :delete, "/job_cards/#{card.id}"
    end
    assert_response :ok
  end

  test "invalid cards are rejected with their errors" do
    sign_in @member

    assert_no_difference -> { JobCard.count } do
      account_request :post, "/job_cards", params: card_params(@member, title: "", slot_start: "8", slot_length: "3")
    end
    assert_response :unprocessable_content
    assert_includes response.parsed_body["errors"], "Title can't be blank"
    assert_includes response.parsed_body["errors"], "Slot length extends beyond session (max slot is 9)"
  end

  test "a lead manages the planner of a subordinate" do
    lead = users(:lead)
    subordinate = users(:subordinate)
    sign_in lead

    account_request :post, "/job_cards", params: card_params(subordinate)
    assert_response :created
    assert_equal subordinate, JobCard.find(response.parsed_body["id"]).user

    card = create_card(subordinate)
    account_request :patch, "/job_cards/#{card.id}", params: { job_card: { title: "Moved" } }
    assert_response :ok
    assert_equal "Moved", card.reload.title
  end

  test "a member can not read or change someone else's planner" do
    other = users(:managed)
    card = create_card(other)
    sign_in @member

    account_request :get, "/job_cards/#{card.id}"
    assert_response :forbidden

    account_request :patch, "/job_cards/#{card.id}", params: { job_card: { title: "Hijacked" } }
    assert_response :forbidden
    assert_equal "Existing card", card.reload.title

    assert_no_difference -> { JobCard.count } do
      account_request :delete, "/job_cards/#{card.id}"
      account_request :post, "/job_cards", params: card_params(other)
    end
    assert_response :forbidden
  end

  test "an update can not move a card to another user" do
    card = create_card(@member)
    sign_in @member

    account_request :patch, "/job_cards/#{card.id}", params: { job_card: { title: "Same owner", user_id: users(:managed).id } }

    assert_response :ok
    assert_equal @member, card.reload.user
  end

  test "users of another account can not reach this account's cards" do
    card = create_card(@member)
    outsider = users(:admin) # an admin of the "fixed" account
    sign_in outsider

    # Through their own account path the card does not exist ...
    account_request :get, "/job_cards/#{card.id}", account: outsider.account
    assert_response :not_found
    account_request :post, "/job_cards", account: outsider.account, params: card_params(@member)
    assert_response :not_found

    # ... and this account's path is not theirs.
    account_request :delete, "/job_cards/#{card.id}"
    assert_response :forbidden
    assert JobCard.exists?(card.id)
  end

  test "signed-out requests are refused" do
    card = create_card(@member)

    account_request :get, "/job_cards/#{card.id}"
    assert_response :unauthorized

    account_request :delete, "/job_cards/#{card.id}"
    assert_response :unauthorized
    assert JobCard.exists?(card.id)
  end

  # The planner hides editing for past days, but that check runs in the browser (and used the
  # browser's clock). The server must refuse on its own date, whatever the client sends.
  test "cards on past days can be read but not changed or deleted" do
    card = create_card(@member, date: Date.current - 1.day)
    sign_in @member

    account_request :get, "/job_cards/#{card.id}"
    assert_response :ok

    account_request :patch, "/job_cards/#{card.id}", params: { job_card: { title: "Rewritten history" } }
    assert_response :forbidden
    assert_equal ["Job cards on past days can't be changed"], response.parsed_body["errors"]
    assert_equal "Existing card", card.reload.title

    account_request :patch, "/job_cards/#{card.id}", params: { job_card: { date: (Date.current + 1.day).iso8601 } }
    assert_response :forbidden
    assert_equal Date.current - 1.day, card.reload.date

    assert_no_difference -> { JobCard.count } do
      account_request :delete, "/job_cards/#{card.id}"
    end
    assert_response :forbidden
  end

  test "a card can not be created on a past day" do
    sign_in @member

    assert_no_difference -> { JobCard.count } do
      account_request :post, "/job_cards", params: card_params(@member, date: (Date.current - 1.day).iso8601)
    end
    assert_response :unprocessable_content
    assert_includes response.parsed_body["errors"], "Date can't be in the past"
  end

  test "a card can not be moved to a past day" do
    card = create_card(@member)
    sign_in @member

    account_request :patch, "/job_cards/#{card.id}", params: { job_card: { date: (Date.current - 1.day).iso8601 } }

    assert_response :unprocessable_content
    assert_includes response.parsed_body["errors"], "Date can't be in the past"
    assert_equal @date, card.reload.date
  end

  test "today's cards can still be changed" do
    card = create_card(@member, date: Date.current)
    sign_in @member

    account_request :patch, "/job_cards/#{card.id}", params: { job_card: { title: "Still today" } }
    assert_response :ok

    account_request :delete, "/job_cards/#{card.id}"
    assert_response :ok
  end

  test "the server's date decides, not the client's" do
    card = create_card(@member, date: Date.current + 1.day)
    sign_in @member

    travel_to Date.current + 2.days do
      account_request :patch, "/job_cards/#{card.id}", params: { job_card: { title: "Too late" } }
      assert_response :forbidden
    end
    assert_equal "Existing card", card.reload.title
  end
end
