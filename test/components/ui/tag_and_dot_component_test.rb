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
