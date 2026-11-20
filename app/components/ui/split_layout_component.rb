# frozen_string_literal: true

module Ui
  # The main page body of detail pages: a wide primary column (lists, tables) and a secondary column
  # (forms, stats) that sits beside it on large screens and below it on small ones.
  #
  #   render Ui::SplitLayoutComponent.new do |layout|
  #     layout.with_primary(id: "todo-list", data: { controller: "infinite-scroll" }) { ... }
  #     layout.with_secondary { ... }
  #   end
  #
  # `inset: false` removes the side gutters (full-bleed tables). The secondary slot is optional.
  class SplitLayoutComponent < ViewComponent::Base
    renders_one :primary, "Ui::SplitLayoutComponent::Column"
    renders_one :secondary, "Ui::SplitLayoutComponent::SideColumn"

    def initialize(inset: true)
      @inset = inset
    end

    def inner_class = @inset ? "px-4 sm:px-6" : nil

    def grid_class = @inset ? "grid items-start grid-cols-1 gap-2 lg:grid-cols-3 lg:gap-2" : "grid items-start grid-cols-1 lg:grid-cols-3"

    class Column < ViewComponent::Base
      BASE = "grid grid-cols-1 gap-4 lg:col-span-2"

      def initialize(**html_options)
        @html_options = html_options
      end

      def call
        content_tag(:div, content, **@html_options, class: [self.class::BASE, @html_options[:class]].compact.join(" "))
      end
    end

    class SideColumn < Column
      BASE = "grid grid-cols-1 gap-4 xl:border-l xl:border-gray-200"
    end
  end
end
