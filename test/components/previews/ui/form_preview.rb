class Ui::FormPreview < ViewComponent::Preview
  def fields
    render_with_template(template: "ui/form_preview/fields")
  end
end
