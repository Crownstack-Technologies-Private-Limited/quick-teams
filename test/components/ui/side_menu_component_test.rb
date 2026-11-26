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

  test "filter layout: bare nav, headings between items, ids kept" do
    render_inline(Ui::SideMenuComponent.new(id: "menu", layout: :filter, label: "Schedule filters")) do |menu|
      menu.with_heading("Teams", id: "teams-headline")
      menu.with_item("All", "/schedules", selected: true)
      menu.with_heading("Jobs")
      menu.with_item("Engineer", "/schedules?job=1", id: "job_1", selected: false)
    end
    assert_no_selector "aside"
    assert_selector "nav#menu[aria-label='Schedule filters'] h3#teams-headline", text: "Teams"
    assert_selector "h3.uppercase", count: 2
    assert_selector "a.selected[aria-current=page]", text: "All"
    assert_selector "a#job_1.unselected span.truncate", text: "Engineer"
  end
end
