# Thin wrappers over Ui::ButtonComponent for the repeated Edit / Delete / confirm links.
module ButtonHelper
  CONFIRM_DELETE_MESSAGE = "Are you sure you want to delete this?".freeze

  def delete_button(path)
    render Ui::ButtonComponent.new("Delete", href: path, variant: :inline_delete, data: confirmation_data(CONFIRM_DELETE_MESSAGE, method: :delete))
  end

  # `style` is a CSS class string for callers that need a different look than the inline delete link.
  def styled_delete_button(path, style)
    render Ui::ButtonComponent.new("Delete", href: path, variant: :plain, class: style, data: confirmation_data(CONFIRM_DELETE_MESSAGE, method: :delete))
  end

  def confirm_button(path, title, message, style)
    render Ui::ButtonComponent.new(title, href: path, variant: :plain, class: style, data: confirmation_data(message))
  end

  def edit_button(path)
    render Ui::ButtonComponent.new("Edit", href: path, variant: :inline_edit)
  end

  def styled_edit_button(path, style)
    render Ui::ButtonComponent.new("Edit", href: path, variant: :plain, class: style)
  end

  private

  def confirmation_data(message, method: nil)
    data = { controller: "confirmation", "confirmation-message-value": message, action: "confirmation#confirm" }
    data[:"turbo-method"] = method if method
    data
  end
end
