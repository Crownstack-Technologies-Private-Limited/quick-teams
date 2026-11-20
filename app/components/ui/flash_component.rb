# frozen_string_literal: true

module Ui
  # Flash message. Keeps `p.notice` / `p.alert` (system tests select them) and hides itself when empty.
  #
  #   render Ui::FlashComponent.new(:notice, notice)
  #   render Ui::FlashComponent.new(:alert, alert)
  class FlashComponent < ViewComponent::Base
    TYPES = {
      notice: { class: "notice flash-notice empty:hidden", role: "status" },
      alert: { class: "alert flash-alert empty:hidden", role: "alert" },
    }.freeze

    def initialize(type, message)
      raise ArgumentError, "Unknown flash type #{type.inspect}" unless TYPES.key?(type)

      @type = type
      @message = message
    end

    def call
      content_tag(:p, @message, **TYPES.fetch(@type))
    end
  end
end
