require "test_helper"

class PlannersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:crownstack)
    ActsAsTenant.current_tenant = @account
    @member = users(:member)
    @monday = Date.new(2026, 11, 23)
  end

  def visit_path(path, account: @account, **options)
    full_path = "/#{account.id}#{path}"
    get full_path, **options, env: { "REQUEST_PATH" => full_path }
  end

  def create_card(user, **attributes)
    JobCard.create!({ user: user, title: "Card", date: @monday, session: "morning", slot_start: 1, slot_length: 1 }.merge(attributes))
  end

  test "the daily planner shows the day's cards of that employee" do
    create_card(@member, title: "Standup notes", slot_start: 2, slot_length: 2, description: "Daily sync")
    create_card(@member, title: "Tomorrow's card", date: @monday + 1.day)
    create_card(users(:managed), title: "Someone else's card")
    sign_in @member

    visit_path "/employees/#{@member.id}/planner/daily", params: { date: @monday.iso8601 }

    assert_response :ok
    assert_select "h2", text: /Daily Planner - Monday, November 23, 2026/
    assert_select ".job-card", count: 1
    assert_select ".job-card[data-card-id] .text-xs", text: "Standup notes"
    assert_select ".job-card", text: /40\s*min/
    assert_select ".slot", count: 27 # 3 sessions x 9 slots
    assert_select "#jobCardModal input[name=user_id][value='#{@member.id}']"
  end

  test "the daily planner defaults to today" do
    sign_in @member

    visit_path "/employees/#{@member.id}/planner/daily"

    assert_response :ok
    assert_select "[data-daily-planner-date-value='#{Date.today.iso8601}']"
  end

  test "the weekly planner shows Monday to Friday" do
    create_card(@member, title: "Monday card")
    create_card(@member, title: "Friday card", date: @monday + 4.days, session: "evening")
    create_card(@member, title: "Saturday card", date: @monday + 5.days)
    sign_in @member

    visit_path "/employees/#{@member.id}/planner/weekly", params: { week: @monday.iso8601 }

    assert_response :ok
    assert_select "h2", text: /Weekly Planner - November 23 -\s+November 27, 2026/
    assert_select "[data-date]", count: 15 # 5 days x 3 sessions
    assert_select "[data-card-id]", count: 2
    assert_select "[data-date='#{(@monday + 4.days).iso8601}'][data-session=evening] [data-card-id]", count: 1
    assert_select "[data-card-id]", text: /Saturday card/, count: 0
  end

  test "a lead sees a subordinate's planner" do
    sign_in users(:lead)

    visit_path "/employees/#{users(:subordinate).id}/planner/weekly"

    assert_response :ok
  end

  test "a member is sent away from someone else's planner" do
    sign_in @member

    visit_path "/employees/#{users(:managed).id}/planner/daily"

    assert_response :redirect
  end

  test "an employee of another account is not found" do
    sign_in users(:regular) # an admin of this account

    visit_path "/employees/#{users(:admin).id}/planner/daily" # users(:admin) belongs to the "fixed" account

    assert_response :redirect
  end
end
