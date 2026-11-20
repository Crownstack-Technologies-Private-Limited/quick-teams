require_relative "../ui_component_test_case"

class Ui::LayoutComponentTest < UiComponentTestCase
  test "split layout renders primary and secondary columns with attributes" do
    render_inline(Ui::SplitLayoutComponent.new) do |layout|
      layout.with_primary(id: "todo-list", data: { controller: "infinite-scroll" }) { "LEFT" }
      layout.with_secondary(id: "new_report") { "RIGHT" }
    end
    assert_selector "main.pb-8 div.px-4 div.grid.lg\\:grid-cols-3"
    assert_selector "div#todo-list.lg\\:col-span-2[data-controller=infinite-scroll]", text: "LEFT"
    assert_selector "div#new_report.xl\\:border-l", text: "RIGHT"
  end

  test "split layout without inset or secondary" do
    render_inline(Ui::SplitLayoutComponent.new(inset: false)) { |layout| layout.with_primary { "ONLY" } }
    assert_no_selector "div.px-4"
    assert_text "ONLY"
  end

  test "page wrapper tag" do
    render_inline(Ui::PageComponent.new) { "x" }
    assert_selector "main.relative.flex-1"
    render_inline(Ui::PageComponent.new(tag: :div)) { "x" }
    assert_selector "div.relative.flex-1"
  end

  test "form container and loading" do
    render_inline(Ui::FormContainerComponent.new(width: "max-w-4xl")) { "form" }
    assert_selector "main.max-w-4xl.space-y-4", text: "form"
    render_inline Ui::LoadingComponent.new("Hold on a sec...")
    assert_selector "p[role=status]", text: "Hold on a sec..."
  end

  test "kebab menu has an accessible trigger and wired dropdown" do
    render_inline(Ui::KebabMenuComponent.new(button_id: "comment-menu", label: "Comment actions")) { "<a class='dropdown-item'>Edit</a>".html_safe }
    assert_selector "div[data-controller=dropdown] button#comment-menu[aria-label='Comment actions'] svg"
    assert_selector "[data-dropdown-target=menu] a.dropdown-item", text: "Edit"
  end

  test "billable avatar" do
    person = Ui::AvatarComponentTest::Person.new("ada", "lovelace")
    person.define_singleton_method(:billable?) { true }
    render_inline Ui::BillableAvatarComponent.new(person)
    assert_selector "span[title=Billable] span.bg-green-400"
  end

  test "alert and settings layout validation" do
    render_inline Ui::AlertComponent.new(:error, title: "2 errors", items: ["a", "b"], id: "error_explanation")
    assert_selector "#error_explanation li", count: 2
    render_inline Ui::AlertComponent.new(:success, message: "Saved")
    assert_selector "p", text: "Saved"
    assert_raises(ArgumentError) { Ui::SettingsLayoutComponent.new(menu: :nope) }
    assert_raises(ArgumentError) { Ui::AlertComponent.new(:warning) }
  end

  test "color picker radios and list row" do
    render_inline Ui::ColorPickerComponent.new(name: "people_tag[color]", selected: "red", id_prefix: "new_people_tag")
    assert_selector "input[type=radio][name='people_tag[color]']", count: 5
    assert_selector "input[value=red][checked]"
    assert_selector "label[for=new_people_tag_blue]", text: "Blue"
    render_inline(Ui::ListRowComponent.new(title: "Engineering", subtitle: "Dept")) { |row| row.with_actions { "ACTIONS" } }
    assert_selector "li p", text: "Engineering"
    assert_text "ACTIONS"
  end

  test "inline errors render nothing when empty" do
    render_inline Ui::InlineErrorsComponent.new(nil)
    assert_no_selector "p"
    render_inline Ui::InlineErrorsComponent.new(["can't be blank"])
    assert_selector "p.text-red-600", text: "can't be blank"
  end
end
