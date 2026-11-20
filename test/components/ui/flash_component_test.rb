require_relative "../ui_component_test_case"

class Ui::FlashComponentTest < UiComponentTestCase
  test "notice" do
    render_inline Ui::FlashComponent.new(:notice, "Saved")
    assert_selector "p.notice.flash-notice[role=status]", text: "Saved"
  end

  test "alert renders even when empty so it can hide itself" do
    render_inline Ui::FlashComponent.new(:alert, nil)
    assert_selector "p.alert.flash-alert.empty\\:hidden[role=alert]", text: ""
  end

  test "unknown type raises" do
    assert_raises(ArgumentError) { Ui::FlashComponent.new(:info, "x") }
  end
end
