class Ui::BadgeComponentPreview < ViewComponent::Preview
  def colors
    render_with_template(template: "ui/badge_component_preview/colors")
  end
end
