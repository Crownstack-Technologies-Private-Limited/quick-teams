# frozen_string_literal: true

module Ui
  # Submit input for a form builder: same <input type="submit"> (name="commit", data-disable-with) as
  # `form.submit`, with the standard button classes.
  #
  #   render Ui::SubmitButtonComponent.new(form, "Save")
  #   render Ui::SubmitButtonComponent.new(form, "Save", class: "ml-2", id: "save")
  class SubmitButtonComponent < ViewComponent::Base
    def initialize(form, label = nil, variant: :primary, size: :md, **html_options)
      raise ArgumentError, "Unknown button variant #{variant.inspect}" unless ButtonComponent::VARIANTS.key?(variant)

      @form = form
      @label = label
      @variant = variant
      @size = size
      @html_options = html_options
    end

    def call
      classes = [ButtonComponent::VARIANTS.fetch(@variant), ButtonComponent::SIZES.fetch(@size), @html_options[:class]].compact.join(" ")
      @form.submit(@label, **@html_options.merge(class: classes))
    end
  end
end
