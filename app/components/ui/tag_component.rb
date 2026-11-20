# frozen_string_literal: true

module Ui
  # Coloured tag chip (project / people tags carry their own Tailwind colour name, e.g. "blue").
  #
  #   render Ui::TagComponent.new(tag.name.upcase_first, color: tag.color)
  class TagComponent < ViewComponent::Base
    def initialize(label = nil, color: "gray", **html_options)
      @label = label
      @color = color
      @html_options = html_options
    end

    def call
      content_tag(:span, content || @label, **@html_options, class: ["inline-flex px-2 text-xs font-semibold leading-5 text-#{@color}-800 bg-#{@color}-100 rounded-full", @html_options[:class]].compact.join(" "))
    end
  end
end
