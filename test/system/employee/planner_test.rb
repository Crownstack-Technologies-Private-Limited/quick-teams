require "application_system_test_case"

class EmployeePlannerTest < ApplicationSystemTestCase
  setup do
    @employee = users(:member)
    @account = @employee.account
    ActsAsTenant.current_tenant = @account
    @date = Date.current + 1.day # the daily planner only edits today and later
    sign_in @employee
  end

  def daily_url(employee = @employee, date: @date)
    employee_planner_daily_url(employee, date: date.iso8601, script_name: "/#{@account.id}")
  end

  def weekly_url(employee = @employee, week: @date.beginning_of_week)
    employee_planner_weekly_url(employee, week: week.iso8601, script_name: "/#{@account.id}")
  end

  def slot(session, number)
    find(".slot[data-session='#{session}'][data-slot='#{number}']")
  end

  test "the navbar links to the employee's own planner" do
    visit employee_schedules_url(@employee, script_name: "/#{@account.id}")
    click_on "JobCards"

    assert_selector "h2", text: "#{@employee.first_name}'s Daily Planner"
  end

  test "can add, edit and delete a job card on the daily planner" do
    visit daily_url
    assert_selector "h2", text: "Daily Planner - #{@date.strftime('%A, %B %d, %Y')}"

    slot("afternoon", 2).click
    within "#jobCardModal" do
      assert_text "Add Job Card"
      fill_in "title", with: "Review pull requests"
      fill_in "description", with: "Upgrade branch first"
      select "3 slots (1h)", from: "slot_length"
      choose "color_blue"
      click_on "Save"
    end

    card = find(".job-card", text: "Review pull requests")
    assert_text "1 h"
    created = JobCard.find_by!(title: "Review pull requests")
    assert_equal [@employee, @date, "afternoon", 2, 3, "blue"], created.values_at(:user, :date, :session, :slot_start, :slot_length, :color)

    card.click
    within "#jobCardModal" do
      assert_text "Edit Job Card"
      assert_field "title", with: "Review pull requests"
      fill_in "title", with: "Review and merge"
      click_on "Update"
    end
    assert_selector ".job-card", text: "Review and merge"
    assert_equal "Review and merge", created.reload.title

    find(".job-card", text: "Review and merge").click
    within "#jobCardModal" do
      accept_confirm { click_on "Delete" }
    end
    assert_no_selector ".job-card"
    assert_not JobCard.exists?(created.id)
    take_screenshot
  end

  test "a card that does not fit in its session is refused" do
    visit daily_url
    slot("morning", 9).click
    within "#jobCardModal" do
      fill_in "title", with: "Too long"
      select "3 slots (1h)", from: "slot_length"
      message = accept_alert { click_on "Save" }
      assert_includes message, "Slot length extends beyond session"
    end
    assert_not JobCard.exists?(title: "Too long")
  end

  test "past days are read-only" do
    JobCard.create!(user: @employee, title: "Yesterday's work", date: Date.current - 1.day, session: "morning", slot_start: 1, slot_length: 1)
    visit daily_url(date: Date.current - 1.day)

    find(".job-card", text: "Yesterday's work").click
    slot("evening", 1).click
    assert_selector "#jobCardModal", visible: :hidden
  end

  test "a browser with its clock set back still can not change a past day" do
    card = JobCard.create!(user: @employee, title: "Yesterday's work", date: Date.current - 1.day, session: "morning", slot_start: 1, slot_length: 1)
    visit daily_url(date: Date.current - 1.day)

    # Move the page's clock back a week, then send what the planner would send.
    result = page.evaluate_async_script(<<~JS, card.id, @account.id)
      const [cardId, accountId, done] = arguments
      const realNow = Date.now()
      Date.now = () => realNow - 7 * 24 * 60 * 60 * 1000
      fetch(`/${accountId}/job_cards/${cardId}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json", "Accept": "application/json" },
        body: JSON.stringify({ job_card: { title: "Rewritten history" } })
      }).then(async (response) => done([response.status, (await response.json()).errors]))
    JS

    assert_equal [403, ["Job cards on past days can't be changed"]], result
    assert_equal "Yesterday's work", card.reload.title

    # The page itself takes the server's word for it, whatever the clock says.
    find(".job-card", text: "Yesterday's work").click
    assert_selector "#jobCardModal", visible: :hidden
  end

  test "the weekly planner shows the week's cards and their details" do
    monday = @date.beginning_of_week
    JobCard.create!(user: @employee, title: "Sprint planning", description: "Bring the backlog", date: monday, session: "morning",
                    slot_start: 1, slot_length: 3, color: "green")
    JobCard.create!(user: @employee, title: "Retro", date: monday + 4.days, session: "evening", slot_start: 1, slot_length: 1)

    visit weekly_url
    assert_selector "h2", text: "Weekly Planner - #{monday.strftime('%B %d')}"
    assert_selector "[data-date='#{monday.iso8601}'][data-session='morning']", text: "Sprint planning"
    assert_selector "[data-date='#{(monday + 4.days).iso8601}'][data-session='evening']", text: "Retro"

    find("[data-card-id]", text: "Sprint planning").click
    within "#jobCardDetailsModal" do
      assert_text "Sprint planning"
      assert_text "Bring the backlog"
      click_on "Close"
    end
    assert_selector "#jobCardDetailsModal", visible: :hidden

    click_on monday.strftime("%a %m/%d")
    assert_selector "h2", text: "Daily Planner - #{monday.strftime('%A, %B %d, %Y')}"
  end

  test "a lead can plan for a subordinate" do
    sign_out @employee
    sign_in users(:lead)
    subordinate = users(:subordinate)

    visit daily_url(subordinate)
    assert_selector "h2", text: "#{subordinate.first_name}'s Daily Planner"
    slot("morning", 1).click
    within "#jobCardModal" do
      fill_in "title", with: "Pair on onboarding"
      click_on "Save"
    end

    assert_selector ".job-card", text: "Pair on onboarding"
    assert_equal subordinate, JobCard.find_by!(title: "Pair on onboarding").user
  end

  test "a member can not open someone else's planner" do
    visit daily_url(users(:managed))

    assert_no_selector "h2", text: "Daily Planner"
  end
end
