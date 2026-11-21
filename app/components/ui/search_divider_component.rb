# frozen_string_literal: true

module Ui
  # Labelled rule between groups of search results ("Projects", "Jobs").
  #
  #   render Ui::SearchDividerComponent.new("Projects")
  class SearchDividerComponent < ViewComponent::Base
    def initialize(label)
      @label = label
    end

    def call
      tag.div(class: "relative") do
        safe_join([
          tag.div(tag.div(class: "w-full border-t border-gray-300"), class: "absolute inset-0 flex items-center", "aria-hidden": "true"),
          tag.div(tag.span(@label, class: "px-4 pr-2 text-sm italic font-bold text-gray-500 bg-white"), class: "relative flex justify-start"),
        ])
      end
    end
  end
end
