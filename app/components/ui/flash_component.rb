# frozen_string_literal: true

module Ui
  # Flash message, shown as a floating toast so it never pushes the page down.
  # Render it inside Ui::ToastRegionComponent (the layout does this). Keeps `p.notice` / `p.alert`
  # (system tests select them). Renders nothing when the message is blank.
  #
  #   render Ui::FlashComponent.new(:notice, notice)   # fades out after a few seconds
  #   render Ui::FlashComponent.new(:alert, alert)     # stays until dismissed
  class FlashComponent < ViewComponent::Base
    NOTICE_DISMISS_AFTER_MS = 6000

    TYPES = {
      notice: { class: "notice flash-notice", role: "status", dismiss_after: NOTICE_DISMISS_AFTER_MS },
      alert: { class: "alert flash-alert", role: "alert", dismiss_after: 0 },
    }.freeze

    def initialize(type, message)
      raise ArgumentError, "Unknown flash type #{type.inspect}" unless TYPES.key?(type)

      @type = type
      @message = message
    end

    def render?
      @message.present?
    end

    def call
      config = TYPES.fetch(@type)
      content_tag(
        :p,
        class: config[:class],
        role: config[:role],
        data: { controller: "auto-dismiss", "auto-dismiss-delay-value": config[:dismiss_after] },
      ) do
        safe_join([tag.span(@message, class: "flash-message"), dismiss_button])
      end
    end

    private

    def dismiss_button
      tag.button(
        type: "button",
        class: "flash-dismiss",
        "aria-label": "Dismiss",
        data: { action: "auto-dismiss#dismiss" },
      ) { render Ui::IconComponent.new(:x_small, class: "h-4 w-4") }
    end
  end
end
