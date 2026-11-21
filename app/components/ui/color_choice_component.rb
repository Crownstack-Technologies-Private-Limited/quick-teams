# frozen_string_literal: true

module Ui
  # Radio list where each choice has a colour swatch and a description (planner card colours).
  #
  #   render Ui::ColorChoiceComponent.new(name: "color", selected: "gray", input_data: { "daily-planner-target": "colorInput" },
  #     options: [["green", "Deep Work, Important or priority tasks"], ["gray", "Breaks, Learning or fun activities"]])
  class ColorChoiceComponent < ViewComponent::Base
    def initialize(name:, options:, selected: nil, input_data: {})
      @name = name
      @options = options
      @selected = selected
      @input_data = input_data
    end
  end
end
