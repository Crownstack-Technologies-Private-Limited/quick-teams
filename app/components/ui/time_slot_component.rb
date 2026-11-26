# frozen_string_literal: true

module Ui
  # One 20 minute slot of the daily planner. Click opens the add-card modal (daily-planner#openModal);
  # the block holds the job card that starts in this slot.
  #
  #   render Ui::TimeSlotComponent.new(session: "morning", number: 3) { render Ui::JobCardComponent.new(...) }
  class TimeSlotComponent < ViewComponent::Base
    def initialize(session:, number:)
      @session = session
      @number = number
    end
  end
end
