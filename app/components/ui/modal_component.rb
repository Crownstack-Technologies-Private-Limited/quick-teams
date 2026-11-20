# frozen_string_literal: true

module Ui
  # Modal dialog rendered into <div id="modal"> (the Stimulus `modal` controller closes it).
  #
  #   render Ui::ModalComponent.new(title: "Deactivate?", icon: :exclamation) do |modal|
  #     modal.with_body { "Are you sure?" }
  #     modal.with_footer do
  #       render(Ui::ButtonComponent.new("Cancel", variant: :secondary, data: { action: "modal#close" }))
  #     end
  #   end
  #
  # Without `title:` the block content is placed straight into the panel (forms, custom headers).
  # The panel is `relative` on purpose: the backdrop is `fixed`, and Tailwind 4's `transform` no longer
  # creates a stacking context, so an un-positioned panel is painted under the backdrop and its buttons
  # become unclickable.
  class ModalComponent < ViewComponent::Base
    renders_one :body
    renders_one :footer

    def initialize(title: nil, icon: nil, tone: :danger, padded: true)
      @title = title
      @icon = icon
      @tone = tone
      @padded = padded
    end

    def panel_padding
      @padded ? "px-4 pt-5 pb-4 sm:p-6" : "px-4 pb-4"
    end

    def icon_classes
      @tone == :danger ? "bg-red-100 text-red-600" : "bg-primary-100 text-primary-700"
    end
  end
end
