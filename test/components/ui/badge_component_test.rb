require_relative "../ui_component_test_case"

class Ui::BadgeComponentTest < UiComponentTestCase
  test "renders color classes" do
    render_inline Ui::BadgeComponent.new("Active", color: :green)
    assert_selector "span.badge-green", text: "Active"
  end

  test "rejects unknown colors" do
    assert_raises(ArgumentError) { Ui::BadgeComponent.new("x", color: :pink) }
  end
end
