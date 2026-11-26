# frozen_string_literal: true

module Ui
  # Radio group for choosing a tag colour; each option shows a coloured chip.
  #
  #   render Ui::ColorPickerComponent.new(name: "people_tag[color]", selected: tag.color, id_prefix: "people_tag")
  class ColorPickerComponent < ViewComponent::Base
    COLORS = %w[gray red yellow green blue].freeze

    def initialize(name:, selected: "gray", id_prefix: nil, colors: COLORS)
      @name = name
      @selected = selected
      @id_prefix = id_prefix
      @colors = colors
    end

    def radio_id(color) = "#{@id_prefix || @name.to_s.parameterize(separator: "_")}_#{color}"
  end
end
