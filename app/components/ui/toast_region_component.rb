# frozen_string_literal: true

module Ui
  # Fixed, top-centred stack for transient messages (flash notices/alerts). It overlays the page
  # instead of taking layout space, and clicks pass through to the page except on the toasts.
  #
  #   render Ui::ToastRegionComponent.new(below_app_bar: user_signed_in?) do
  #     render Ui::FlashComponent.new(:notice, notice)
  #   end
  class ToastRegionComponent < ViewComponent::Base
    def initialize(below_app_bar: false)
      @below_app_bar = below_app_bar
    end

    def call
      tag.div(content, id: "toasts", class: ["toast-region", (@below_app_bar ? "top-16" : "top-4")].join(" "), "aria-live": "polite")
    end
  end
end
