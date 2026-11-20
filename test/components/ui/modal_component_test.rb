require_relative "../ui_component_test_case"

class Ui::ModalComponentTest < UiComponentTestCase
  test "renders the overlay with the modal controller and a positioned panel" do
    render_inline(Ui::ModalComponent.new(title: "Deactivate?", icon: :exclamation)) do |modal|
      modal.with_body { "Are you sure?" }
      modal.with_footer { "BUTTONS" }
    end
    assert_selector "div#modal [data-controller=modal][role=dialog][aria-modal=true][data-action='keyup@document->modal#escClose']"
    assert_selector "h3#modal-title", text: "Deactivate?"
    assert_text "Are you sure?"
    assert_text "BUTTONS"
    assert_selector "div.relative.rounded-xl.bg-white"
    assert_selector "svg[aria-hidden=true]"
  end

  test "without a title only the block is rendered" do
    render_inline(Ui::ModalComponent.new(padded: false)) { "CUSTOM" }
    assert_no_selector "h3"
    assert_text "CUSTOM"
  end
end
