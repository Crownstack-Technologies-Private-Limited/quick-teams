# frozen_string_literal: true

module Ui
  # "More actions" (⋯) menu: an icon-only trigger button and a dropdown panel with the block's links.
  #
  #   render Ui::KebabMenuComponent.new(button_id: "comment-menu", label: "Comment actions") do
  #     link_to("Edit", edit_path, class: "dropdown-item", role: "menuitem")
  #   end
  #
  # Wraps Ui::DropdownComponent (Stimulus `dropdown` controller); the label becomes the button's aria-label.
  class KebabMenuComponent < ViewComponent::Base
    def initialize(button_id:, label:, icon: :dots_vertical, icon_class: "h-5 w-5", bordered: false)
      @button_id = button_id
      @label = label
      @icon = icon
      @icon_class = icon_class
      @bordered = bordered
    end

    def button_class
      base = "flex-auto mt-1 ml-4 text-sm rounded-full hover:text-gray-600 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
      @bordered ? "#{base} border border-gray-400" : base
    end
  end
end
