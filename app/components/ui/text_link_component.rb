# frozen_string_literal: true

module Ui
  # Brand-coloured inline text link (auth pages, "forgot password", footers).
  #
  #   render Ui::TextLinkComponent.new("Log in", new_user_session_path)
  class TextLinkComponent < ViewComponent::Base
    def initialize(label, href, **html_options)
      @label = label
      @href = href
      @html_options = html_options
    end

    def call
      link_to(content || @label, @href, **@html_options, class: ["font-medium text-primary-700 hover:text-primary-800 hover:underline", @html_options[:class]].compact.join(" "))
    end
  end
end
