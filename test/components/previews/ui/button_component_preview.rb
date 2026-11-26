class Ui::ButtonComponentPreview < ViewComponent::Preview
  def variants
    render_with_template(template: "ui/button_component_preview/variants")
  end

  def primary = render(Ui::ButtonComponent.new("New Project", href: "#"))
  def secondary = render(Ui::ButtonComponent.new("Cancel", href: "#", variant: :secondary))
  def danger = render(Ui::ButtonComponent.new("Delete account", href: "#", variant: :danger))
  def small = render(Ui::ButtonComponent.new("Small", href: "#", size: :sm))
  def inline_actions = render(Ui::ButtonComponent.new("Edit", href: "#", variant: :inline_edit))
end
