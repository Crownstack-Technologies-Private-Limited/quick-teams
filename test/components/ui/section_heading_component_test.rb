require_relative "../ui_component_test_case"

class Ui::SectionHeadingComponentTest < UiComponentTestCase
  test "title and subtitle" do
    render_inline Ui::SectionHeadingComponent.new(title: "Add New Employee", subtitle: "Please add detail.")
    assert_selector "h1", text: "Add New Employee"
    assert_selector "p", text: "Please add detail."
  end

  test "can use another heading tag and takes actions" do
    render_inline(Ui::SectionHeadingComponent.new(title: "Tags", tag: :h2)) { "ACTION" }
    assert_selector "h2", text: "Tags"
    assert_text "ACTION"
  end
end
