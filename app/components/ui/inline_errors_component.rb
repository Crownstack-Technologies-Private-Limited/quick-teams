# frozen_string_literal: true

module Ui
  # Validation messages shown above an inline edit row. Renders nothing for nil / empty.
  #
  #   render Ui::InlineErrorsComponent.new(local_assigns[:messages])
  class InlineErrorsComponent < ViewComponent::Base
    def initialize(messages)
      @messages = Array(messages)
    end

    def render?
      @messages.any?
    end

    def call
      safe_join(@messages.map { |message| content_tag(:p, message, class: "mt-2 text-sm text-red-600") })
    end
  end
end
