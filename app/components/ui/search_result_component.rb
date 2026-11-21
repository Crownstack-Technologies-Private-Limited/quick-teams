# frozen_string_literal: true

module Ui
  # One option in a live-search results list (rendered into the `results` target of Ui::SearchFieldComponent).
  # With `href:` the option sits inside a link; reflex options pass `data:` / `id:`.
  #
  #   render Ui::SearchResultComponent.new(href: employee_team_path(e)) { e.display_name }
  #   render Ui::SearchResultComponent.new(id: "add", data: { reflex: "click->EmployeeSkills#add", "skill-id": s.id }) { s.name }
  class SearchResultComponent < ViewComponent::Base
    CLASSES = "block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 hover:text-gray-900"

    def initialize(href: nil, **html_options)
      @href = href
      @html_options = html_options
    end

    def call
      option = content_tag(:li, content, **@html_options, role: "option", class: [CLASSES, @html_options[:class]].compact.join(" "))
      @href ? link_to(option, @href) : option
    end
  end
end
