class Ui::NavigationPreview < ViewComponent::Preview
  def nav_items
    render_with_template(template: "ui/navigation_preview/nav_items")
  end

  def side_menu
    render(Ui::SideMenuComponent.new) do |menu|
      menu.with_item("Account", "#", icon: :cog, selected: true)
      menu.with_item("Billing", "#", icon: :currency_dollar)
      menu.with_item("Job Profiles", "#", icon: :briefcase)
    end
  end
end
