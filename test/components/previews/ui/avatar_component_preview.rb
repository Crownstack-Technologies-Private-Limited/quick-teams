class Ui::AvatarComponentPreview < ViewComponent::Preview
  Person = Struct.new(:first_name, :last_name) do
    def avatar = Struct.new(:attached?).new(false)
  end

  def sizes
    render_with_template(template: "ui/avatar_component_preview/sizes", locals: { person: Person.new("Ada", "Lovelace") })
  end

  def group
    render Ui::AvatarGroupComponent.new([Person.new("Ada", "Lovelace"), Person.new("Alan", "Turing"), Person.new("Grace", "Hopper")], overflow: "+2 more", title: "Ada, Alan, Grace")
  end
end
