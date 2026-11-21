# frozen_string_literal: true

module Ui
  # A paragraph with the app's text scale: size, tone and alignment instead of hand-written class strings.
  #
  #   render Ui::TextComponent.new("No record found.", align: :right)
  #   render Ui::TextComponent.new("Occupancy 80%", size: :xl, tone: :strong, align: :right, class: "px-8")
  class TextComponent < ViewComponent::Base
    SIZES = { sm: "text-sm", xl: "text-xl" }.freeze
    TONES = { muted: "text-gray-500", strong: "font-medium text-gray-900" }.freeze
    ALIGNS = { left: nil, right: "text-right", center: "text-center" }.freeze

    def initialize(text = nil, size: :sm, tone: :muted, align: :left, **html_options)
      raise ArgumentError, "Unknown text size #{size.inspect}" unless SIZES.key?(size)
      raise ArgumentError, "Unknown text tone #{tone.inspect}" unless TONES.key?(tone)
      raise ArgumentError, "Unknown text alignment #{align.inspect}" unless ALIGNS.key?(align)

      @text = text
      @size = size
      @tone = tone
      @align = align
      @html_options = html_options
    end

    def call
      classes = [SIZES.fetch(@size), TONES.fetch(@tone), ALIGNS.fetch(@align), @html_options[:class]].compact.join(" ")
      content_tag(:p, content || @text, **@html_options, class: classes)
    end
  end
end
