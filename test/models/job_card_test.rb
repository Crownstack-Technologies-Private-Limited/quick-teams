require "test_helper"

class JobCardTest < ActiveSupport::TestCase
  setup do
    ActsAsTenant.current_tenant = accounts(:crownstack)
    @user = users(:member)
  end

  def build_card(**attributes)
    JobCard.new({ user: @user, title: "Write specs", date: Date.new(2026, 11, 23), session: "morning", slot_start: 1, slot_length: 1 }.merge(attributes))
  end

  test "a card defaults to gray" do
    card = build_card
    assert card.valid?
    assert_equal "gray", card.color
    assert_equal "bg-gray-500", card.color_class
    assert_equal "bg-gray-400", card.weekly_color_class
  end

  test "a card needs a title, a date, a session and a slot" do
    card = JobCard.new(user: @user)
    assert_not card.valid?
    assert_includes card.errors[:title], "can't be blank"
    assert_includes card.errors[:date], "can't be blank"
    assert_includes card.errors[:session], "can't be blank"
    assert_includes card.errors[:slot_start], "can't be blank"
  end

  test "slots run from 1 to 9 and a card may not run past the end of its session" do
    assert_not build_card(slot_start: 0).valid?
    assert_not build_card(slot_start: 10).valid?
    assert build_card(slot_start: 7, slot_length: 3).valid?

    card = build_card(slot_start: 8, slot_length: 3)
    assert_not card.valid?
    assert_includes card.errors[:slot_length], "extends beyond session (max slot is 9)"
  end

  test "slot_end and height follow the slot length" do
    card = build_card(slot_start: 2, slot_length: 3)
    assert_equal 4, card.slot_end
    assert_equal 7.5, card.height_rem
  end

  test "colors map to their classes" do
    assert_equal "bg-red-500", build_card(color: "red").color_class
    assert_equal "bg-green-400", build_card(color: "green").weekly_color_class
  end

  test "for_date and for_week select cards by date" do
    monday = Date.new(2026, 11, 23)
    monday_card = build_card(date: monday).tap(&:save!)
    sunday_card = build_card(date: monday + 6.days).tap(&:save!)
    next_monday_card = build_card(date: monday + 7.days).tap(&:save!)

    assert_equal [monday_card], JobCard.for_date(monday).to_a
    assert_equal [monday_card, sunday_card].sort_by(&:id), JobCard.for_week(monday).order(:id).to_a
    assert_not_includes JobCard.for_week(monday), next_monday_card
  end

  test "deleting a user deletes their job cards" do
    user = User.create!(first_name: "Card", last_name: "Owner", email: "card.owner@crownstack.com", password: "Sup3r-secret!",
                        account: accounts(:crownstack), role: roles(:senior), job: jobs(:ios), discipline: disciplines(:engineering),
                        confirmed_at: Time.current)
    build_card(user: user).save!

    assert_difference -> { JobCard.count }, -1 do
      user.destroy!
    end
  end

  test "past cards are not editable and the planner may not put a card in the past" do
    assert build_card(date: Date.current).editable?
    assert_not build_card(date: Date.current - 1.day).editable?

    past = build_card(date: Date.current - 1.day)
    assert past.valid? # history (fixtures, imports) is still valid
    assert_not past.valid?(:planner)
    assert_includes past.errors[:date], "can't be in the past"

    card = build_card(date: Date.current + 1.day).tap(&:save!)
    card.title = "Renamed"
    assert card.valid?(:planner)
    card.date = Date.current - 1.day
    assert_not card.valid?(:planner)
  end
end
