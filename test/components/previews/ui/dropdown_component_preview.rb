class Ui::DropdownComponentPreview < ViewComponent::Preview
  def default
    render(Ui::DropdownComponent.new(button_id: "menu-button")) do |dd|
      dd.with_trigger { "Status" }
      dd.with_item("Active")
      dd.with_item("On leave")
    end
  end

  def icon_trigger
    render(Ui::DropdownComponent.new(label: "More", button_variant: :nav, chevron: false)) do |dd|
      dd.with_trigger { render Ui::IconComponent.new(:dots_horizontal) }
      dd.with_item("Tickets")
      dd.with_item("Surveys & KPIs")
    end
  end
end
