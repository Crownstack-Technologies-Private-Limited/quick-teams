# frozen_string_literal: true

module Ui
  # Row of form buttons aligned to the end (Back + Save).
  #
  #   render Ui::FormActionsComponent.new do
  #     safe_join([render(Ui::BackButtonComponent.new), form.submit("Save", class: "btn-primary ml-2")])
  #   end
  class FormActionsComponent < ViewComponent::Base
    def initialize(align: :end)
      @align = align
    end

    def call
      content_tag(:div, content, class: "flex #{@align == :end ? "justify-end" : "justify-start"}")
    end
  end
end
