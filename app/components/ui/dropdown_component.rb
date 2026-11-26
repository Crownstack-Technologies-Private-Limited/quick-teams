# frozen_string_literal: true

module Ui
  # Dropdown menu driven by the Stimulus `dropdown` controller (click toggles, click outside / Esc hides).
  #
  #   render Ui::DropdownComponent.new(button_id: "menu-button", button_variant: :secondary) do |dd|
  #     dd.with_trigger { "Status" }
  #     dd.with_item("Active", "#", data: { reflex: "click->EmployeeStatus#change" })
  #   end
  #
  # Icon-only triggers must pass `label:` (becomes aria-label).
  class DropdownComponent < ViewComponent::Base
    renders_one :trigger
    renders_many :items, "Ui::DropdownComponent::Item"

    def initialize(button_id: nil, label: nil, button_variant: :secondary, button_class: nil, button_data: {}, width: "w-56", align: :right, chevron: true, wrapper_class: nil)
      @button_id = button_id
      @label = label
      @button_variant = button_variant
      @button_class = button_class
      @button_data = button_data
      @width = width
      @align = align
      @chevron = chevron
      @wrapper_class = wrapper_class
    end

    def button_classes
      base = { secondary: "btn-secondary", nav: "nav-unselected inline-flex items-center gap-1", icon: "icon-btn", plain: "" }.fetch(@button_variant)
      [base, @button_class].compact.join(" ")
    end

    def align_class = @align == :right ? "right-0 origin-top-right" : "left-0 origin-top-left"

    class Item < ViewComponent::Base
      def initialize(label, href = "#", **html_options)
        @label = label
        @href = href
        @html_options = html_options
      end

      def call
        link_to(content || @label, @href, **@html_options, class: ["dropdown-item", @html_options[:class]].compact.join(" "), role: "menuitem")
      end
    end
  end
end
