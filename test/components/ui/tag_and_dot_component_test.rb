require_relative "../ui_component_test_case"

class Ui::TagAndDotComponentTest < UiComponentTestCase
  test "tag uses its colour name" do
    render_inline Ui::TagComponent.new("Design", color: "blue")
    assert_selector "span.text-blue-800.bg-blue-100.rounded-full", text: "Design"
  end

  test "status dot" do
    render_inline Ui::StatusDotComponent.new(color: "green")
    assert_selector "span.bg-green-400.rounded-full"
  end
end

class Ui::TagComponentRemovableTest < UiComponentTestCase
  test "removable chip keeps its id and data attributes" do
    render_inline Ui::TagComponent.new("Star", color: "red", size: :sm, remove: { id: "remove", data: { reflex: "click->EmployeeTags#remove", "tag-id": 3 } })
    assert_selector "span.text-red-800.bg-red-100", text: "Star"
    assert_selector "button#remove[type=button][aria-label='Remove Star'][data-reflex='click->EmployeeTags#remove'][data-tag-id='3'] svg"
  end
end

class Ui::TextLinkAndTimelineTest < UiComponentTestCase
  test "text link tones" do
    render_inline Ui::TextLinkComponent.new("Ada", "/u/1", tone: :strong)
    assert_selector "a.font-medium.text-gray-900.hover\\:underline[href='/u/1']", text: "Ada"
    render_inline Ui::TextLinkComponent.new("Log in", "/login")
    assert_selector "a.text-primary-700", text: "Log in"
  end

  test "timeline item" do
    person = Ui::AvatarComponentTest::Person.new("ada", "lovelace")
    render_inline(Ui::TimelineItemComponent.new(user: person, timestamp: "Nov 20")) { "added a goal" }
    assert_selector "li span.rounded-full", text: "AL"
    assert_selector "p.text-gray-500", text: "added a goal"
    assert_text "Nov 20"
  end
end
