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
end
