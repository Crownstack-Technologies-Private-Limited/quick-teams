# frozen_string_literal: true

module Ui
  # Metric: small muted label, large value. `variant: :card` is a bordered tile; `:plain` sits inline in a grid.
  #
  #   render Ui::StatCardComponent.new(label: "Billable", value: 12, hint: "of 20 resources")
  #   render Ui::StatCardComponent.new(label: "Total Hours", value: stats.total_hours, variant: :plain)
  class StatCardComponent < ViewComponent::Base
    VARIANTS = { card: "card px-5 py-4", plain: "px-4 overflow-hidden" }.freeze

    def initialize(label:, value:, hint: nil, href: nil, variant: :card, **html_options)
      raise ArgumentError, "Unknown stat variant #{variant.inspect}" unless VARIANTS.key?(variant)

      @label = label
      @value = value
      @hint = hint
      @href = href
      @variant = variant
      @html_options = html_options
    end

    def wrapper_options
      @html_options.merge(class: [VARIANTS.fetch(@variant), @html_options[:class]].compact.join(" "))
    end
  end
end
