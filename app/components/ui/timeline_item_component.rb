# frozen_string_literal: true

module Ui
  # One entry of the activity feed: avatar on the connecting line, sentence (block content), timestamp on the right.
  #
  #   render Ui::TimelineItemComponent.new(user: event.user, timestamp: display_created_at(event)) do
  #     "Ada added a goal ..."
  #   end
  class TimelineItemComponent < ViewComponent::Base
    def initialize(user:, timestamp:)
      @user = user
      @timestamp = timestamp
    end
  end
end
