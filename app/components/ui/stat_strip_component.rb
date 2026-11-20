# frozen_string_literal: true

module Ui
  # Row of centred headline numbers (report totals). Four across on medium screens, stacked on mobile.
  #
  #   render Ui::StatStripComponent.new(columns: 4) do |strip|
  #     strip.with_stat("Logged Hours", stats.total_hours)
  #   end
  class StatStripComponent < ViewComponent::Base
    COLUMNS = { 3 => "md:grid-cols-3", 4 => "md:grid-cols-4", 5 => "md:grid-cols-5" }.freeze

    renders_many :stats, "Ui::StatStripComponent::Stat"

    def initialize(columns: 4)
      raise ArgumentError, "columns must be one of #{COLUMNS.keys}" unless COLUMNS.key?(columns)

      @columns = columns
    end

    def columns_class = COLUMNS.fetch(@columns)

    class Stat < ViewComponent::Base
      def initialize(label, value)
        @label = label
        @value = value
      end

      def call
        content_tag(:div, class: "px-4 py-2 sm:p-2") do
          safe_join([
            content_tag(:dt, @label, class: "text-base font-normal text-center text-gray-900"),
            content_tag(:div, @value, class: "flex items-baseline justify-center text-xl font-semibold text-gray-600"),
          ])
        end
      end
    end
  end
end
