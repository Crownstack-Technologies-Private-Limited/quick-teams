require_relative "../ui_component_test_case"

class Ui::StatCardComponentTest < UiComponentTestCase
  test "renders label, value and hint" do
    render_inline Ui::StatCardComponent.new(label: "Billable", value: 12, hint: "of 20")
    assert_selector "dt", text: "Billable"
    assert_selector "dd", text: "12"
    assert_text "of 20"
  end

  test "links the value when href is given" do
    render_inline Ui::StatCardComponent.new(label: "Open", value: 3, href: "/tickets")
    assert_selector "dd a[href='/tickets']", text: "3"
  end

  test "plain variant is an inline definition pair" do
    render_inline Ui::StatCardComponent.new(label: "Total Hours", value: 8, variant: :plain)
    assert_selector "div.px-4.overflow-hidden dt", text: "Total Hours"
    assert_selector "dd.text-xl", text: "8"
    assert_raises(ArgumentError) { Ui::StatCardComponent.new(label: "x", value: 1, variant: :huge) }
  end
end
