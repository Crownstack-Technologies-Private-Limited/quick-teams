require_relative "../ui_component_test_case"

class Ui::FlashComponentTest < UiComponentTestCase
  test "notice is a status toast that fades out" do
    render_inline Ui::FlashComponent.new(:notice, "Saved")
    assert_selector "p.notice.flash-notice[role=status][data-controller=auto-dismiss]", text: "Saved"
    assert_selector "p.notice[data-auto-dismiss-delay-value='#{Ui::FlashComponent::NOTICE_DISMISS_AFTER_MS}']"
    assert_selector "p.notice button.flash-dismiss[aria-label=Dismiss][data-action='auto-dismiss#dismiss']"
  end

  test "alert stays until dismissed" do
    render_inline Ui::FlashComponent.new(:alert, "Invalid email or password.")
    assert_selector "p.alert.flash-alert[role=alert][data-auto-dismiss-delay-value='0']", text: "Invalid email or password."
    assert_selector "p.alert button.flash-dismiss[aria-label=Dismiss]"
  end

  test "renders nothing when the message is blank" do
    render_inline Ui::FlashComponent.new(:alert, nil)
    assert_no_selector "p"
    render_inline Ui::FlashComponent.new(:notice, "")
    assert_no_selector "p"
  end

  test "unknown type raises" do
    assert_raises(ArgumentError) { Ui::FlashComponent.new(:info, "x") }
  end
end
