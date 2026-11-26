# frozen_string_literal: true

module Ui
  # Status pill / tag / count. Wraps .badge-{color}.
  #
  #   render Ui::BadgeComponent.new("Active", color: :green)
  class BadgeComponent < ViewComponent::Base
    COLORS = %i[gray brand green amber red].freeze

    def initialize(label = nil, color: :gray, **html_options)
      raise ArgumentError, "Unknown badge color #{color.inspect}" unless COLORS.include?(color)

      @label = label
      @color = color
      @html_options = html_options
    end

    def call
      content_tag(:span, content || @label, **@html_options, class: ["badge-#{@color}", @html_options[:class]].compact.join(" "))
    end
  end
end
