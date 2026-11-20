require_relative "../ui_component_test_case"

class Ui::AvatarComponentTest < UiComponentTestCase
  Person = Struct.new(:first_name, :last_name) do
    def avatar = Struct.new(:attached?).new(false)
  end

  test "shows uppercase initials when there is no image" do
    render_inline Ui::AvatarComponent.new(Person.new("ada", "lovelace"), size: :sm)
    assert_selector "span.rounded-full.w-8.h-8", text: "AL"
  end

  test "group renders every avatar plus the overflow label" do
    people = [Person.new("a", "b"), Person.new("c", "d")]
    render_inline Ui::AvatarGroupComponent.new(people, overflow: "+3", title: "a b, c d")
    assert_selector "div[title='a b, c d'] span.rounded-full", count: 2
    assert_text "+3"
  end

  test "rejects unknown size" do
    assert_raises(ArgumentError) { Ui::AvatarComponent.new(Person.new("a", "b"), size: :huge) }
  end
end
