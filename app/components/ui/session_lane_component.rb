# frozen_string_literal: true

module Ui
  # One session (morning / afternoon / evening) of one day in the weekly planner; holds that day's job cards.
  #
  #   render Ui::SessionLaneComponent.new(date: date.iso8601, session: "morning") { cards }
  class SessionLaneComponent < ViewComponent::Base
    def initialize(date:, session:)
      @date = date
      @session = session
    end

    def call
      content_tag(:div, content, class: "session-slot border border-gray-200 rounded flex-1 space-y-1 p-1 overflow-y-auto", data: { date: @date, session: @session }, "aria-label": @session.to_s.capitalize)
    end
  end
end
