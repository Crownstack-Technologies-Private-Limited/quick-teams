# frozen_string_literal: true

module Ui
  # The white card holding an auth form, with validation errors above it.
  # Render it inside `form_for` so the card's fields belong to the form.
  #
  #   render Ui::AuthCardComponent.new(resource: resource, class: "mt-4") do
  #     ...fields...
  #   end
  class AuthCardComponent < ViewComponent::Base
    def initialize(resource: nil, **html_options)
      @resource = resource
      @html_options = html_options
    end

    def card_options
      gap = "mt-4" if @resource&.errors&.any? # keep the validation box and the card apart
      @html_options.merge(class: ["card space-y-5 px-5 py-8 shadow-sm sm:px-10", gap, @html_options[:class]].compact.join(" "))
    end
  end
end
