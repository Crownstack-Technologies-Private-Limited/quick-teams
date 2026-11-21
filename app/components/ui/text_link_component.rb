# frozen_string_literal: true

module Ui
  # Inline text link. tone: :brand (auth pages, "forgot password") :strong (names inside sentences) or :row (record names in table rows) or :plain (wraps larger blocks).
  #
  #   render Ui::TextLinkComponent.new("Log in", new_user_session_path)
  #   render Ui::TextLinkComponent.new(user.display_name, employee_path(user), tone: :strong)
  class TextLinkComponent < ViewComponent::Base
    TONES = {
      brand: "font-medium text-primary-700 hover:text-primary-800 hover:underline",
      strong: "font-medium text-gray-900 hover:underline",
      row: "truncate hover:text-gray-600 hover:underline",
      plain: "focus:outline-none",
    }.freeze

    def initialize(label, href, tone: :brand, **html_options)
      raise ArgumentError, "Unknown link tone #{tone.inspect}" unless TONES.key?(tone)

      @label = label
      @href = href
      @tone = tone
      @html_options = html_options
    end

    def call
      link_to(content || @label, @href, **@html_options, class: [TONES.fetch(@tone), @html_options[:class]].compact.join(" "))
    end
  end
end
