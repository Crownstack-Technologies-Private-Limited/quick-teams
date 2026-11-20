class Ui::PageHeaderComponentPreview < ViewComponent::Preview
  def with_action
    render(Ui::PageHeaderComponent.new(title: "Projects", subtitle: "(12 projects)")) do |header|
      header.with_actions { render Ui::ButtonComponent.new("New Project", href: "#") }
    end
  end

  def title_only = render(Ui::PageHeaderComponent.new(title: "Timesheets"))
end
