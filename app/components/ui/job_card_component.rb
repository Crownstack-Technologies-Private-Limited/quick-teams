# frozen_string_literal: true

module Ui
  # A planner job card: coloured block with title (and, on the daily planner, duration and description).
  # The colour classes come from the JobCard model; dark text is used on the light green / yellow backgrounds.
  #
  #   render Ui::JobCardComponent.new(title: card.title, color_class: card.color_class, duration: "1h 20m",
  #     description: card.description, style: "height: 5.25rem; z-index: 1;", data: { "card-id": card.id })
  #   render Ui::JobCardComponent.new(title: card.title, color_class: card.weekly_color_class, variant: :weekly, ...)
  class JobCardComponent < ViewComponent::Base
    VARIANTS = {
      daily: "job-card absolute inset-0 rounded p-1 cursor-pointer overflow-hidden",
      weekly: "job-card inset-x-2 rounded p-1 overflow-hidden cursor-pointer",
    }.freeze

    def initialize(title:, color_class:, duration: nil, description: nil, variant: :daily, **html_options)
      raise ArgumentError, "Unknown job card variant #{variant.inspect}" unless VARIANTS.key?(variant)

      @title = title
      @color_class = color_class
      @duration = duration
      @description = description
      @variant = variant
      @html_options = html_options
    end

    def text_class = @color_class.to_s.match?(/green|yellow/) ? "text-gray-900" : "text-white"

    def wrapper_options
      @html_options.merge(class: [VARIANTS.fetch(@variant), @color_class, text_class, @html_options[:class]].compact.join(" "))
    end
  end
end
