# frozen_string_literal: true

module Ui
  # Joined row of links that act like a segmented control (Daily | Weekly, Previous | Today | Next).
  # `selected: true` marks the current one (aria-current="page").
  #
  #   render Ui::SegmentedLinksComponent.new(label: "Planner view") do |links|
  #     links.with_link("Daily Planner", employee_planner_daily_path, selected: true)
  #     links.with_link("Weekly Planner", employee_planner_weekly_path)
  #   end
  class SegmentedLinksComponent < ViewComponent::Base
    renders_many :links, "Ui::SegmentedLinksComponent::Segment"

    def initialize(label: nil)
      @label = label
    end

    class Segment < ViewComponent::Base
      BASE = "relative inline-flex items-center px-3 py-1.5 text-sm font-medium border focus:z-10 first:rounded-l-md last:rounded-r-md not-first:-ml-px"
      IDLE = "text-gray-700 bg-white border-gray-300 hover:bg-gray-50"
      CURRENT = "text-primary-700 bg-primary-50 border-primary-300"

      def initialize(label, href, selected: false, **html_options)
        @label = label
        @href = href
        @selected = selected
        @html_options = html_options
      end

      def call
        link_to(content || @label, @href, **@html_options, class: [BASE, (@selected ? CURRENT : IDLE), @html_options[:class]].compact.join(" "), "aria-current": (@selected ? "page" : nil))
      end
    end
  end
end
