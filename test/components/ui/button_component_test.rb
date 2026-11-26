require_relative "../ui_component_test_case"

class Ui::ButtonComponentTest < UiComponentTestCase
  test "renders a link button with the primary class" do
    render_inline Ui::ButtonComponent.new("New Project", href: "/projects/new")
    assert_selector "a.btn-primary[href='/projects/new']", text: "New Project"
  end

  test "renders a <button> without href and defaults type to button" do
    render_inline Ui::ButtonComponent.new("Save", variant: :secondary)
    assert_selector "button.btn-secondary[type=button]", text: "Save"
  end

  test "passes data and aria attributes and extra classes through" do
    render_inline Ui::ButtonComponent.new("Delete", href: "/x", variant: :inline_delete, class: "ml-2", data: { controller: "confirmation" }, "aria-label": "Delete x")
    assert_selector "a.btn-inline-delete.ml-2[data-controller=confirmation][aria-label='Delete x']"
  end

  test "small size adds btn-sm" do
    render_inline Ui::ButtonComponent.new("Go", href: "/", size: :sm)
    assert_selector "a.btn-primary.btn-sm"
  end

  test "block content wins over the label" do
    render_inline(Ui::ButtonComponent.new(href: "/", variant: :icon, "aria-label": "Edit")) { "pencil" }
    assert_selector "a.icon-btn[aria-label=Edit]", text: "pencil"
  end

  test "rejects unknown variants" do
    assert_raises(ArgumentError) { Ui::ButtonComponent.new("x", variant: :bogus) }
  end
end
