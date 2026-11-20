# frozen_string_literal: true

module Ui
  # Metric tile: big value, small label, optional hint.
  #
  #   render Ui::StatCardComponent.new(label: "Billable", value: 12, hint: "of 20 resources")
  class StatCardComponent < ViewComponent::Base
    def initialize(label:, value:, hint: nil, href: nil, **html_options)
      @label = label
      @value = value
      @hint = hint
      @href = href
      @html_options = html_options
    end

    def wrapper_options
      @html_options.merge(class: ["card px-5 py-4", @html_options[:class]].compact.join(" "))
    end
  end
end
