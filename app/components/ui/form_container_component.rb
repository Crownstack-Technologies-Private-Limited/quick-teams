# frozen_string_literal: true

module Ui
  # Centered narrow column that holds a form page (heading, fields, buttons) with consistent spacing.
  #
  #   render Ui::FormContainerComponent.new { ...form fields... }
  #   render Ui::FormContainerComponent.new(width: "max-w-2xl", class: "z-10")
  class FormContainerComponent < ViewComponent::Base
    def initialize(width: "max-w-lg", **html_options)
      @width = width
      @html_options = html_options
    end

    def call
      content_tag(:main, content, **@html_options, class: [@width, "px-4 pt-6 pb-12 mx-auto space-y-4 lg:pb-16", @html_options[:class]].compact.join(" "))
    end
  end
end
