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
