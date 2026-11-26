# frozen_string_literal: true

module Ui
  # Joined row of secondary buttons (segmented control). Rounding of the first and last button comes from CSS.
  #
  #   render Ui::ButtonGroupComponent.new do |group|
  #     group.with_button("Last Week", data: { reflex: "click->EmployeeTimesheetsStats#last_week", "reflex-dataset": "combined" })
  #     group.with_button("Last Month", data: { reflex: "click->EmployeeTimesheetsStats#last_month", "reflex-dataset": "combined" })
  #   end
  class ButtonGroupComponent < ViewComponent::Base
    renders_many :buttons, "Ui::ButtonGroupComponent::Segment"

    class Segment < ViewComponent::Base
      CLASSES = "relative inline-flex items-center px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 hover:bg-gray-50 focus:z-10 focus:outline-none focus:ring-1 focus:ring-primary-500 focus:border-primary-500 first:rounded-l-md last:rounded-r-md not-first:-ml-px"

      def initialize(label = nil, **html_options)
        @label = label
        @html_options = html_options
      end

      def call
        content_tag(:button, content || @label, type: "button", **@html_options, class: [CLASSES, @html_options[:class]].compact.join(" "))
      end
    end
  end
end
