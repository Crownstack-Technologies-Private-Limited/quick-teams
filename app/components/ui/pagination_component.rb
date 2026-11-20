# frozen_string_literal: true

module Ui
  # Right-aligned pagination bar around the Pagy nav (shared/_paginator keeps the Pagy 43 logic).
  #
  #   render Ui::PaginationComponent.new(@pagy)
  class PaginationComponent < ViewComponent::Base
    def initialize(pagy, align: :end, **html_options)
      @pagy = pagy
      @align = align
      @html_options = html_options
    end

    def call
      justify = @align == :end ? "justify-end" : "justify-center"
      content_tag(:div, helpers.render(partial: "shared/paginator", locals: { pagy: @pagy }), **@html_options, class: ["flex #{justify} mt-2 mb-6 mr-2", @html_options[:class]].compact.join(" "))
    end
  end
end
