# frozen_string_literal: true

module Ui
  # Vertical settings/account menu (aside). Items are links with an icon; the current page is highlighted.
  #
  #   render Ui::SideMenuComponent.new(id: "menu") do |menu|
  #     menu.with_item("Account", detail_path, icon: :cog)
  #   end
  class SideMenuComponent < ViewComponent::Base
    renders_many :items, "Ui::SideMenuComponent::Item"

    def initialize(id: "menu", label: "Settings")
      @id = id
      @label = label
    end

    class Item < ViewComponent::Base
      def initialize(label, href, icon: nil, selected: nil)
        @label = label
        @href = href
        @icon = icon
        @selected = selected
      end

      def selected?
        @selected.nil? ? helpers.current_page?(@href) : @selected
      end

      def call
        link_to(@href, class: selected? ? "selected" : "unselected", "aria-current": (selected? ? "page" : nil)) do
          safe_join([
            (render(Ui::IconComponent.new(@icon, class: "svg-icon")) if @icon),
            content_tag(:span, content || @label, class: "truncate"),
          ].compact)
        end
      end
    end
  end
end
