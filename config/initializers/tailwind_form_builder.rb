class TailwindFormBuilder < ActionView::Helpers::FormBuilder
  # text_field/text_area/password_field take the label as the second argument. When it is left out
  # (form.text_field :name, placeholder: "Add New Tag"), the options go to the input and the label
  # is the attribute's name.
  %w[rich_text_area].each do |method_name|
    define_method(method_name) do |name, title, *args|
      @template.content_tag :div do
        label(name, title, class: "form-label") +
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
      label(method, title, class: "form-label") +
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
      label(method, title, class: "form-label") +
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
      label(method, title, class: "form-label") +
      (@template.content_tag :div, class: "mt-1" do
        super(method, merged_opts)
      end)
    end
  end

  # Selects in these forms have no visible <label>; name them for assistive tech (prompt text, else the attribute).
  def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
    super(method, collection, value_method, text_method, options, { "aria-label": accessible_name(method, options) }.merge(html_options))
  end

  def select(method, choices = nil, options = {}, html_options = {}, &block)
    super(method, choices, options, { "aria-label": accessible_name(method, options) }.merge(html_options), &block)
  end

  private

  def accessible_name(method, options)
    options[:prompt].presence&.to_s&.delete_prefix("Select ") || method.to_s.humanize.delete_suffix(" id")
  end
end
