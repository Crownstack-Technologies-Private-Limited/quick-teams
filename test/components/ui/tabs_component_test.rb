require_relative "../ui_component_test_case"

class Ui::TabsComponentTest < UiComponentTestCase
  test "wrapper keeps its id and the current page tab is selected" do
    with_request_url "/tickets/open" do
      render_inline(Ui::TabsComponent.new(id: "ticket-tabs")) do |tabs|
        tabs.with_tab("Open Tickets", "/tickets/open")
        tabs.with_tab("Closed Tickets", "/tickets/closed")
      end
    end
    assert_selector "div#ticket-tabs nav.tab-bar[aria-label=Tabs]"
    assert_selector "a.selected-tab[aria-current=page][href='/tickets/open']", text: "Open Tickets"
    assert_selector "a.unselected-tab[href='/tickets/closed']", text: "Closed Tickets"
    assert_no_selector "a.unselected-tab[aria-current]"
  end
end
