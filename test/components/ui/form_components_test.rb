require_relative "../ui_component_test_case"

class Ui::FormComponentsTest < UiComponentTestCase
  test "form field wraps label, control, help and error" do
    render_inline(Ui::FormFieldComponent.new(label: "Name", for_id: "n", help: "Shown on reports", error: "can't be blank")) { "<input id='n'>".html_safe }
    assert_selector "label.form-label[for=n]", text: "Name"
    assert_selector "input#n"
    assert_selector "p.form-help", text: "Shown on reports"
    assert_selector "p[role=alert]", text: "can't be blank"
  end

  test "checkbox field" do
    render_inline(Ui::CheckboxFieldComponent.new(label: "Billable", for_id: "b")) { "<input type=checkbox id='b'>".html_safe }
    assert_selector "label[for=b]", text: "Billable"
    assert_selector "input#b[type=checkbox]"
  end

  test "form actions align end" do
    render_inline(Ui::FormActionsComponent.new) { "BTNS" }
    assert_selector "div.flex.justify-end", text: "BTNS"
  end

  test "back button goes back in history" do
    render_inline Ui::BackButtonComponent.new(class: "mr-2")
    assert_selector "a.btn-secondary.mr-2[href='javascript:history.back()']", text: "Back"
  end
end
