# frozen_string_literal: true

module Ui
  # Inline group of radio buttons with coloured labels (the "Nature of comment" choice).
  #
  #   render Ui::RadioGroupComponent.new(name: "comment[status]", label: "Nature Of comment", selected: "stale",
  #     options: [["progress", "Progress", "green"], ["stale", "Stale", "yellow"], ["regress", "Regress", "red"]])
  class RadioGroupComponent < ViewComponent::Base
    def initialize(name:, options:, label: nil, selected: nil, **html_options)
      @name = name
      @options = options
      @label = label
      @selected = selected
      @html_options = html_options
    end

    def radio_id(value) = "#{@name.to_s.parameterize(separator: "_")}_#{value}"
  end
end
