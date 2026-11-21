# frozen_string_literal: true

module Ui
  # Titled list of links (the reports index: "Goals", "Schedules"...).
  #
  #   render Ui::LinkListComponent.new(title: "Goals") do |list|
  #     list.with_link("All Pending goals", goals_reports_path(status: 0))
  #   end
  class LinkListComponent < ViewComponent::Base
    renders_many :links, "Ui::LinkListComponent::Link"

    def initialize(title:, heading_id: "projects-headline", first: false)
      @title = title
      @heading_id = heading_id
      @first = first
    end

    class Link < ViewComponent::Base
      def initialize(label, href)
        @label = label
        @href = href
      end

      def call
        link_to(@href, class: "flex items-center px-3 py-1 text-sm text-gray-600 rounded-md group hover:text-gray-900 hover:bg-gray-50") do
          content_tag(:span, content || @label, class: "truncate")
        end
      end
    end
  end
end
