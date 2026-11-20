require_relative "../ui_component_test_case"

class Ui::NavItemComponentTest < UiComponentTestCase
  test "desktop link is selected on its own page" do
    with_request_url "/projects" do
      render_inline Ui::NavItemComponent.new("Projects", "/projects")
    end
    assert_selector "a.nav-selected[aria-current=page]", text: "Projects"
  end

  test "desktop link is unselected elsewhere" do
    with_request_url "/employees" do
      render_inline Ui::NavItemComponent.new("Projects", "/projects")
    end
    assert_selector "a.nav-unselected", text: "Projects"
    assert_no_selector "a[aria-current]"
  end

  test "mobile variant" do
    with_request_url "/projects" do
      render_inline Ui::NavItemComponent.new("Projects", "/projects", mobile: true)
    end
    assert_selector "a.mobile-nav-link.bg-primary-50[aria-current=page]"
  end
end
