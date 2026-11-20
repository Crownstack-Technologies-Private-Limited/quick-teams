# frozen_string_literal: true

module Ui
  # Page title row: <h1> + optional meta (count / position) on the left, actions on the right.
  #
  #   render Ui::PageHeaderComponent.new(title: "Projects", subtitle: "(12 projects)") do |header|
  #     header.with_actions { render Ui::ButtonComponent.new("New Project", href: new_project_path) }
  #   end
  #
  # `bordered: false` drops the bottom border and white band (headers that sit inside a tab layout).
  # The block's own content (not the actions slot) is rendered under the title row, e.g. a search field.
  class PageHeaderComponent < ViewComponent::Base
    renders_one :actions
    renders_one :meta

    def initialize(title:, subtitle: nil, bordered: true, **html_options)
      @title = title
      @subtitle = subtitle
      @bordered = bordered
      @html_options = html_options
    end

    def wrapper_options
      base = @bordered ? "px-4 py-5 bg-white border-b border-gray-200 sm:flex sm:items-center sm:justify-between sm:px-6 lg:px-8" : "px-4 py-4 sm:flex sm:items-center sm:justify-between sm:px-6 lg:px-8"
      @html_options.merge(class: [base, @html_options[:class]].compact.join(" "))
    end
  end
end
