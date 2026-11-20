# frozen_string_literal: true

module Ui
  # Inline message box: success confirmation or a list of validation errors.
  #
  #   render Ui::AlertComponent.new(:success, message: "Saved", data: { controller: "auto-dismiss" })
  #   render Ui::AlertComponent.new(:error, title: "2 errors prohibited this user from being saved:", items: user.errors.full_messages, id: "error_explanation")
  class AlertComponent < ViewComponent::Base
    TONES = {
      success: { box: "border-green-200 bg-green-50", icon: :check_circle, icon_class: "text-green-400", title: "text-green-800", body: "text-green-800" },
      error: { box: "border-red-200 bg-red-50", icon: :x_circle, icon_class: "text-red-500", title: "text-red-800", body: "text-red-700" },
    }.freeze

    def initialize(tone, message: nil, title: nil, items: [], **html_options)
      raise ArgumentError, "Unknown alert tone #{tone.inspect}" unless TONES.key?(tone)

      @tone = TONES.fetch(tone)
      @message = message
      @title = title
      @items = items
      @html_options = html_options
    end

    def wrapper_options
      @html_options.merge(class: ["rounded-lg border p-4", @tone[:box], @html_options[:class]].compact.join(" "))
    end
  end
end
