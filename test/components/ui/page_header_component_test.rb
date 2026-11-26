require_relative "../ui_component_test_case"

class Ui::PageHeaderComponentTest < UiComponentTestCase
  test "renders title, subtitle and actions" do
    render_inline(Ui::PageHeaderComponent.new(title: "Projects", subtitle: "(3 projects)")) do |header|
      header.with_actions { "ACTION" }
    end
    assert_selector "h1", text: "Projects"
    assert_text "(3 projects)"
    assert_text "ACTION"
    assert_selector "div.border-b"
  end

  test "omits subtitle and actions when not given" do
    render_inline Ui::PageHeaderComponent.new(title: "Reports", bordered: false, id: "hdr")
    assert_selector "#hdr h1", text: "Reports"
    assert_no_selector "p"
    assert_no_selector "div.border-b"
  end
end
