# Thin wrappers over Ui::ButtonComponent for the repeated Edit / Delete / confirm links.
module ButtonHelper
  CONFIRM_DELETE_MESSAGE = "Are you sure you want to delete this?".freeze

  def delete_button(path)
    render Ui::ButtonComponent.new("Delete", href: path, variant: :inline_delete, data: confirmation_data(CONFIRM_DELETE_MESSAGE, method: :delete))
  end

  # `style` is a CSS class string for callers that need a different look than the inline delete link.
  def styled_delete_button(path, style)
    render Ui::ButtonComponent.new("Delete", href: path, **button_style(style), data: confirmation_data(CONFIRM_DELETE_MESSAGE, method: :delete))
  end

  def confirm_button(path, title, message, style)
    render Ui::ButtonComponent.new(title, href: path, **button_style(style), data: confirmation_data(message))
  end

  def edit_button(path)
    render Ui::ButtonComponent.new("Edit", href: path, variant: :inline_edit)
  end

  def styled_edit_button(path, style)
    render Ui::ButtonComponent.new("Edit", href: path, **button_style(style))
  end

  private

  STYLE_VARIANTS = { "btn-primary" => :primary, "btn-secondary" => :secondary, "btn-red" => :danger, "btn-ghost" => :ghost }.freeze

  # Splits a legacy style string ("ml-2 btn-secondary") into component options (variant + extra classes).
  def button_style(style)
    tokens = style.to_s.split
    variant_token = tokens.find { |token| STYLE_VARIANTS.key?(token) }
    size = tokens.delete("btn-sm") ? :sm : :md
    tokens.delete(variant_token)
    { variant: STYLE_VARIANTS.fetch(variant_token, :plain), size: size, class: tokens.join(" ").presence }.compact
  end

  def confirmation_data(message, method: nil)
    data = { controller: "confirmation", "confirmation-message-value": message, action: "confirmation#confirm" }
    data[:"turbo-method"] = method if method
    data
  end
end
