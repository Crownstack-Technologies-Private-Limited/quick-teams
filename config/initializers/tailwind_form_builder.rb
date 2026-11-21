class TailwindFormBuilder < ActionView::Helpers::FormBuilder
  # text_field/text_area/password_field take the label as the second argument. When it is left out
  # (form.text_field :name, placeholder: "Add New Tag"), the options go to the input and the label
  # is the attribute's name.
  %w[rich_text_area].each do |method_name|
    define_method(method_name) do |name, title, *args|
      @template.content_tag :div do
        label(name, title, class: "block text-sm font-medium text-gray-700") +
        (@template.content_tag :div, class: "mt-1" do
          super(name, options.reverse_merge(class: "form-text-field"))
        end)
      end
    end
  end

  def text_field(method, title = nil, opts = {})
    title, opts = nil, title if title.is_a?(Hash) # form.text_field :name, placeholder: "..."
    default_opts = { class: "form-text-field #{"border-red-400" if @object.errors.any?}" }
    merged_opts = default_opts.merge(opts)
    @template.content_tag :div do
      label(method, title, class: "block text-sm font-medium text-gray-700") +
      (@template.content_tag :div, class: "mt-1" do
        super(method, merged_opts)
      end)
    end
  end

  def text_area(method, title = nil, opts = {})
    title, opts = nil, title if title.is_a?(Hash) # form.text_area :name, placeholder: "..."
    default_opts = { class: "form-text-field h-24" }
    merged_opts = default_opts.merge(opts)
    @template.content_tag :div do
      label(method, title, class: "block text-sm font-medium text-gray-700") +
      (@template.content_tag :div, class: "mt-1" do
        super(method, merged_opts)
      end)
    end
  end

  def password_field(method, title = nil, opts = {})
    title, opts = nil, title if title.is_a?(Hash) # form.password_field :name, placeholder: "..."
    default_opts = { class: "form-text-field #{"border-red-400" if @object.errors.any?}" }
    merged_opts = default_opts.merge(opts)
    @template.content_tag :div do
      label(method, title, class: "block text-sm font-medium text-gray-700") +
      (@template.content_tag :div, class: "mt-1" do
        super(method, merged_opts)
      end)
    end
  end
end
