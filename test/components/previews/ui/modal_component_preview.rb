class Ui::ModalComponentPreview < ViewComponent::Preview
  def confirm
    render_with_template(template: "ui/modal_component_preview/confirm")
  end
end
