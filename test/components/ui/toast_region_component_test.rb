require_relative "../ui_component_test_case"

class Ui::ToastRegionComponentTest < UiComponentTestCase
  test "fixed live region below the app bar for signed-in pages" do
    render_inline(Ui::ToastRegionComponent.new(below_app_bar: true)) { "toast" }
    assert_selector "div#toasts.toast-region.top-16[aria-live=polite]", text: "toast"
  end

  test "sits near the top edge when there is no app bar" do
    render_inline(Ui::ToastRegionComponent.new) { "toast" }
    assert_selector "div#toasts.toast-region.top-4"
  end
end
