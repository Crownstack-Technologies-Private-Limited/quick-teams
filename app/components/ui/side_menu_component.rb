# frozen_string_literal: true

module Ui
  # Vertical menu of links with an icon (settings, account, archive) or plain text (filters). The current page is
  # highlighted. Group headings can be mixed between the items.
  #
  #   render Ui::SideMenuComponent.new(id: "menu") do |menu|
  #     menu.with_item("Account", detail_path, icon: :cog)
  #   end
  #
  #   # Filter list (schedules): bare nav with group headings, no page column, item ids kept
  #   render Ui::SideMenuComponent.new(id: "menu", layout: :filter, label: "Schedule filters") do |menu|
  #     menu.with_heading("Teams", id: "teams-headline")
  #     menu.with_item("All", schedules_path, selected: true)
  #     menu.with_heading("Jobs")
  #     menu.with_item(job.name, schedules_path(job: job.id), id: dom_id(job), selected: params[:job].to_i == job.id)
  #   end
  class SideMenuComponent < ViewComponent::Base
    renders_many :entries, types: {
      item: { renders: "Ui::SideMenuComponent::Item", as: :item },
      heading: { renders: "Ui::SideMenuComponent::Heading", as: :heading },
    }

    def initialize(id: nil, label: "Settings", layout: :page)
      @id = id
      @label = label
      @layout = layout
    end

    def filter? = @layout == :filter

    class Item < ViewComponent::Base
      def initialize(label, href, icon: nil, selected: nil, **html_options)
        @label = label
        @href = href
        @icon = icon
        @selected = selected
        @html_options = html_options
      end

      def selected?
        @selected.nil? ? helpers.current_page?(@href) : @selected
      end

      def call
        link_to(@href, **@html_options, class: selected? ? "selected" : "unselected", "aria-current": (selected? ? "page" : nil)) do
          safe_join([
            (render(Ui::IconComponent.new(@icon, class: "svg-icon")) if @icon),
            content_tag(:span, content || @label, class: ["truncate", ("ml-2" unless @icon)].compact.join(" ")),
          ].compact)
        end
      end
    end

    class Heading < ViewComponent::Base
      def initialize(label, **html_options)
        @label = label
        @html_options = html_options
      end

      def call
        content_tag(:h3, content || @label, **@html_options, class: "px-3 pt-4 pb-1 text-xs font-semibold tracking-wider text-gray-500 uppercase")
      end
    end
  end
end
