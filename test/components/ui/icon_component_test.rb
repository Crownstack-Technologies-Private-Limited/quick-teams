require_relative "../ui_component_test_case"

class Ui::IconComponentTest < UiComponentTestCase
  test "decorative by default" do
    render_inline Ui::IconComponent.new(:search, class: "h-4 w-4")
    assert_selector "svg.h-4.w-4[aria-hidden=true][fill=currentColor] path"
  end

  test "outline icons stroke" do
    render_inline Ui::IconComponent.new(:cog)
    assert_selector "svg[stroke=currentColor][fill=none]"
  end

  test "label makes it an image for assistive tech" do
    render_inline Ui::IconComponent.new(:search, label: "Search")
    assert_selector "svg[role=img][aria-label=Search]"
    assert_no_selector "svg[aria-hidden]"
  end

  test "every registered icon renders" do
    Ui::IconComponent.names.each do |name|
      render_inline Ui::IconComponent.new(name)
      assert_selector "svg path"
    end
  end

  test "unknown icon raises" do
    assert_raises(ArgumentError) { Ui::IconComponent.new(:nope) }
  end
end
