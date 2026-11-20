# frozen_string_literal: true

module Ui
  # Data table: header row from `columns`, body rows from the block (usually a partial per row).
  #
  #   render Ui::TableComponent.new(wrapper_class: "hidden sm:block") do |table|
  #     table.with_column { sort_link(column: "name", label: "Project") }
  #     table.with_column("Participants")
  #     render partial: "project", collection: @projects
  #   end
  #
  # Body rows keep using the .table-cell class. On small screens the wrapper scrolls instead of widening the page.
  class TableComponent < ViewComponent::Base
    renders_many :columns, "Ui::TableComponent::Column"

    def initialize(wrapper_class: nil, table_class: nil, body_id: nil, **table_options)
      @wrapper_class = wrapper_class
      @table_class = table_class
      @body_id = body_id
      @table_options = table_options
    end

    class Column < ViewComponent::Base
      def initialize(label = nil, **html_options)
        @label = label
        @html_options = html_options
      end

      def call
        content_tag(:th, content || @label, **@html_options, class: ["table-head", @html_options[:class]].compact.join(" "))
      end
    end
  end
end
