require_relative "../ui_component_test_case"

class Ui::DropdownComponentTest < UiComponentTestCase
  test "wires the Stimulus dropdown controller and renders items" do
    render_inline(Ui::DropdownComponent.new(button_id: "menu-button")) do |dd|
      dd.with_trigger { "Status" }
      dd.with_item("Active", "#", data: { reflex: "click->EmployeeStatus#change" })
    end
    assert_selector "div[data-controller=dropdown][data-action*='dropdown#hide']"
    assert_selector "button#menu-button.btn-secondary[data-action='click->dropdown#toggle'][data-dropdown-target=button]", text: "Status"
    assert_selector "div[data-dropdown-target=menu].hidden[role=menu]"
    assert_selector "a.dropdown-item[role=menuitem][data-reflex='click->EmployeeStatus#change']", text: "Active"
  end

  test "icon-only trigger carries aria-label" do
    render_inline(Ui::DropdownComponent.new(label: "More", button_variant: :nav, chevron: false)) { |dd| dd.with_trigger { "..." } }
    assert_selector "button[aria-label=More]"
    assert_no_selector "button svg"
  end
end
