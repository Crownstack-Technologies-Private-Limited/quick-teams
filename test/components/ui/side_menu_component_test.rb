require_relative "../ui_component_test_case"

class Ui::SideMenuComponentTest < UiComponentTestCase
  test "renders items with icons and marks the current one" do
    with_request_url "/account/jobs" do
      render_inline(Ui::SideMenuComponent.new(id: "menu")) do |menu|
        menu.with_item("Job Profiles", "/account/jobs", icon: :briefcase)
        menu.with_item("Roles", "/account/roles", icon: :tag)
      end
    end
    assert_selector "aside nav#menu a.selected[aria-current=page] svg.svg-icon", count: 1
    assert_selector "a.selected span.truncate", text: "Job Profiles"
    assert_selector "a.unselected", text: "Roles"
  end
end
