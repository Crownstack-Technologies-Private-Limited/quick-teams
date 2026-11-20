require_relative "../ui_component_test_case"

class Ui::EmptyStateComponentTest < UiComponentTestCase
  test "defaults to No result found" do
    render_inline Ui::EmptyStateComponent.new
    assert_selector ".empty-state h3", text: "No result found"
  end

  test "message, icon and extra content" do
    render_inline(Ui::EmptyStateComponent.new(title: "No tickets", message: "Nothing yet", icon: :ticket)) { "CTA" }
    assert_selector ".empty-state svg"
    assert_text "Nothing yet"
    assert_text "CTA"
  end
end
