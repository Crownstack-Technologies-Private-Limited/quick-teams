# frozen_string_literal: true

module Ui
  # Horizontal tab bar of links; the current page is selected (aria-current="page").
  #
  #   render Ui::TabsComponent.new(id: "ticket-tabs") do |tabs|
  #     tabs.with_tab("Open Tickets", ticket_open_path)
  #     tabs.with_tab("Closed Tickets", ticket_closed_path)
  #   end
  #
  # `id:` is the wrapper id that tests and turbo-frame targets rely on (e.g. "employee-tabs").
  class TabsComponent < ViewComponent::Base
    renders_many :tabs, "Ui::TabsComponent::Tab"

    def initialize(id:, label: "Tabs")
      @id = id
      @label = label
    end

    class Tab < ViewComponent::Base
      def initialize(label, href, selected: nil, **html_options)
        @label = label
        @href = href
        @selected = selected
        @html_options = html_options
      end

      def selected?
        @selected.nil? ? helpers.current_page?(@href) : @selected
      end

      def call
        link_to(content || @label, @href, **@html_options.merge(class: selected? ? "selected-tab" : "unselected-tab"), "aria-current": (selected? ? "page" : nil))
      end
    end
  end
end
