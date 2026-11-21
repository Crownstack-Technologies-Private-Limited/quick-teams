require_relative "../ui_component_test_case"

class Ui::RemainingComponentsTest < UiComponentTestCase
  test "link list renders a titled list of links" do
    render_inline(Ui::LinkListComponent.new(title: "Goals", first: true)) do |list|
      list.with_link("All Pending goals", "/goals?status=0")
      list.with_link("Recent", "/goals")
    end
    assert_selector "h3#projects-headline.uppercase", text: "Goals"
    assert_no_selector "h3.mt-8"
    assert_selector "div[aria-labelledby=projects-headline] a[href='/goals?status=0'] span.truncate", text: "All Pending goals"
    assert_selector "a", count: 2
  end

  test "search result inside a link, or alone with reflex data" do
    render_inline(Ui::SearchResultComponent.new(href: "/employees/1")) { "Ada (Dev)" }
    assert_selector "a[href='/employees/1'] li[role=option]", text: "Ada (Dev)"
    render_inline(Ui::SearchResultComponent.new(id: "add-skill", class: "cursor-pointer", data: { reflex: "click->ProjectSkills#add", "skill-id": 3 })) { "Ruby" }
    assert_no_selector "a"
    assert_selector "li#add-skill.cursor-pointer[role=option][data-reflex='click->ProjectSkills#add'][data-skill-id='3']", text: "Ruby"
  end

  test "search divider" do
    render_inline Ui::SearchDividerComponent.new("Projects")
    assert_selector "span.italic", text: "Projects"
    assert_selector "[aria-hidden=true] .border-t"
  end

  test "text component scale" do
    render_inline Ui::TextComponent.new("No record found.", align: :right, class: "pr-4")
    assert_selector "p.text-sm.text-gray-500.text-right.pr-4", text: "No record found."
    render_inline Ui::TextComponent.new("Occupancy 80%", size: :xl, tone: :strong)
    assert_selector "p.text-xl.font-medium.text-gray-900"
    assert_raises(ArgumentError) { Ui::TextComponent.new("x", size: :huge) }
  end

  test "button group joins buttons and keeps reflex data" do
    render_inline(Ui::ButtonGroupComponent.new) do |group|
      group.with_button("Last Week", data: { reflex: "click->EmployeeTimesheetsStats#last_week", "reflex-dataset": "combined" })
      group.with_button("Last Month")
    end
    assert_selector "span.inline-flex button[type=button]", count: 2
    assert_selector "button.first\\:rounded-l-md[data-reflex='click->EmployeeTimesheetsStats#last_week'][data-reflex-dataset=combined]", text: "Last Week"
  end

  test "radio group labels every radio and checks the selected one" do
    render_inline Ui::RadioGroupComponent.new(name: "comment[status]", label: "Nature Of comment", selected: "stale",
                                              options: [["progress", "Progress", "green"], ["stale", "Stale", "yellow"]])
    assert_selector "[role=radiogroup][aria-label='Nature Of comment'] input[type=radio][name='comment[status]']", count: 2
    assert_selector "input[value=stale][checked]"
    assert_selector "label[for=comment_status_progress]", text: "Progress"
  end

  test "split submit button adds a menu only when it has options" do
    form = ActionView::Helpers::FormBuilder.new(:comment, nil, vc_test_controller.view_context, {})
    render_inline(Ui::SplitSubmitButtonComponent.new(form, "Comment")) { |button| button.with_option("and mark closed") }
    assert_selector "input[type=submit][value=Comment].rounded-l-md"
    assert_selector "button#option-menu-button[data-action*='dropdown#toggle'][aria-label='Open options']"
    assert_selector "[data-dropdown-target=menu] input[type=submit][value='and mark closed']"

    render_inline Ui::SplitSubmitButtonComponent.new(form, "Comment")
    assert_selector "input[type=submit].rounded-md"
    assert_no_selector "[data-dropdown-target=menu]"
  end
end
