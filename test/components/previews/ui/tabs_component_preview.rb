class Ui::TabsComponentPreview < ViewComponent::Preview
  def default
    render(Ui::TabsComponent.new(id: "demo-tabs")) do |tabs|
      tabs.with_tab("Timeline", "#", selected: true)
      tabs.with_tab("Team", "#")
      tabs.with_tab("Schedules", "#")
    end
  end
end
