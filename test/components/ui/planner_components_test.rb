require_relative "../ui_component_test_case"

class Ui::PlannerComponentsTest < UiComponentTestCase
  include PlannerHelper

  test "segmented links mark the current one" do
    render_inline(Ui::SegmentedLinksComponent.new(label: "Planner view")) do |links|
      links.with_link("Daily Planner", "/planner/daily", selected: true)
      links.with_link("Weekly Planner", "/planner/weekly")
    end
    assert_selector "nav[aria-label='Planner view'] a", count: 2
    assert_selector "a[aria-current=page].text-primary-700", text: "Daily Planner"
    assert_selector "a.first\\:rounded-l-md", text: "Daily Planner"
    assert_no_selector "a[href='/planner/weekly'][aria-current]"
  end

  test "job card keeps its data attributes and picks readable text" do
    render_inline Ui::JobCardComponent.new(title: "Standup", color_class: "bg-yellow-500", duration: "20 min", description: "Daily", style: "height: 2.5rem;", data: { "card-id": 7 })
    assert_selector ".job-card.absolute.bg-yellow-500.text-gray-900[data-card-id='7'][style*='height: 2.5rem']"
    assert_selector ".truncate", text: "Standup"
    assert_text "20 min"
    assert_text "Daily"
    render_inline Ui::JobCardComponent.new(title: "Retro", color_class: "bg-red-400", variant: :weekly, data: { action: "click->weekly-planner#showCardDetails" })
    assert_selector ".job-card.inset-x-2.text-white[data-action='click->weekly-planner#showCardDetails']"
    assert_no_selector ".opacity-90"
  end

  test "time slot opens the modal through its data attributes" do
    render_inline(Ui::TimeSlotComponent.new(session: "afternoon", number: 2)) { "CARD" }
    assert_selector ".slot[data-session=afternoon][data-slot='2'][data-action='click->daily-planner#openModal']", text: "Slot 2 (20 min)"
    assert_text "CARD"
  end

  test "session lane" do
    render_inline(Ui::SessionLaneComponent.new(date: "2026-11-16", session: "morning")) { "x" }
    assert_selector ".session-slot[data-date='2026-11-16'][data-session=morning]"
  end

  test "toggle modal is hidden, labelled, and keeps title options" do
    render_inline(Ui::ToggleModalComponent.new(id: "jobCardModal", title: "Add Job Card", title_options: { data: { "daily-planner-target": "modalTitle" } })) do |modal|
      modal.with_header_actions { "ACTIONS" }
      "BODY"
    end
    assert_selector "#jobCardModal.hidden[role=dialog][aria-modal=true][aria-labelledby='jobCardModal-title']", visible: :all
    assert_selector "h3#jobCardModal-title[data-daily-planner-target=modalTitle]", text: "Add Job Card", visible: :all
    assert_includes rendered_content, "ACTIONS"
    assert_includes rendered_content, "BODY"
  end

  test "colour choice radios carry the controller target" do
    render_inline Ui::ColorChoiceComponent.new(name: "color", selected: "gray", input_data: { "daily-planner-target": "colorInput" },
                                                options: [["green", "Deep work"], ["gray", "Breaks"]])
    assert_selector "input[type=radio][name=color][data-daily-planner-target=colorInput]", count: 2
    assert_selector "input#color_gray[checked]"
    assert_selector "label[for=color_green] span.bg-green-500", text: ""
    assert_text "Deep work"
  end

  test "status banner with a reflex action" do
    render_inline(Ui::StatusBannerComponent.new(tone: :success, color: "green")) do |banner|
      banner.with_action("Reopen", data: { reflex: "click->TodoReflex#toggle_todo", id: 5 })
      "This todo has been completed."
    end
    assert_selector ".bg-green-100 svg"
    assert_selector "button[type=button][data-reflex='click->TodoReflex#toggle_todo'][data-id='5']", text: "Reopen"
    assert_text "This todo has been completed."
    assert_raises(ArgumentError) { Ui::StatusBannerComponent.new(tone: :loud) }
  end

  test "duration label helper" do
    assert_equal "20 min", slot_duration_label(1)
    assert_equal "1h", slot_duration_label(3)
    assert_equal "1h 20m", slot_duration_label(4)
    assert_equal "1 h 20 m", slot_duration_label(4, spaced: true)
  end

  test "info alert takes block content" do
    render_inline(Ui::AlertComponent.new(:info, id: "alert-1")) { "Open the planner" }
    assert_selector "#alert-1.bg-primary-50", text: "Open the planner"
  end
end
