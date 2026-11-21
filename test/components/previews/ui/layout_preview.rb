class Ui::LayoutPreview < ViewComponent::Preview
  def split_layout
    render_with_template(template: "ui/layout_preview/split_layout")
  end

  def timeline
    render_with_template(template: "ui/layout_preview/timeline")
  end

  def kebab_menu
    render(Ui::KebabMenuComponent.new(button_id: "demo-menu", label: "Actions")) do
      "<a class='dropdown-item' role='menuitem' href='#'>Edit</a><a class='dropdown-item' role='menuitem' href='#'>Delete</a>".html_safe
    end
  end

  def list_rows
    render_with_template(template: "ui/layout_preview/list_rows")
  end

  def link_list
    render(Ui::LinkListComponent.new(title: "Goals", first: true)) do |list|
      list.with_link("All Pending goals", "#")
      list.with_link("Recently completed goals", "#")
    end
  end

  def search_results
    render_with_template(template: "ui/layout_preview/search_results")
  end

  def button_group
    render(Ui::ButtonGroupComponent.new) do |group|
      group.with_button("Last Week")
      group.with_button("Last Month")
    end
  end

  def radio_group
    render Ui::RadioGroupComponent.new(name: "comment[status]", label: "Nature Of comment", selected: "stale",
                                       options: [["progress", "Progress", "green"], ["stale", "Stale", "yellow"], ["regress", "Regress", "red"]])
  end

  def text
    render_with_template(template: "ui/layout_preview/text")
  end
end
