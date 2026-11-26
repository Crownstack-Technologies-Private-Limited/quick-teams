# frozen_string_literal: true

module Ui
  # Data table: header row from `columns`, body rows from the block (usually a partial per row).
  #
  #   render Ui::TableComponent.new(body_options: { id: "todos", data: { "infinite-scroll-target": "entries" } }) do |table|
  #     table.with_column("Done")
  #     table.with_column { sort_link(column: "name", label: "Project") }
  #     render partial: "todo", collection: @todos
  #   end
  #
  # `table_class:` adds classes to the <table> (e.g. "table-auto"); `body_options:` become attributes of <tbody>
  # (id, data-infinite-scroll-target...). Body rows keep using the .table-cell class. Put the table inside a
  # scrolling wrapper (`overflow-x-auto`) when it can be wider than the viewport.
  class TableComponent < ViewComponent::Base
    renders_many :columns, "Ui::TableComponent::Column"

    def initialize(table_class: nil, body_options: {}, **table_options)
      @table_class = table_class
      @body_options = body_options
      @table_options = table_options
    end

    def table_options
      @table_options.merge(class: ["table", @table_class].compact.join(" "))
    end

    def body_attributes
      @body_options.merge(class: ["table-body", @body_options[:class]].compact.join(" "))
    end

    class Column < ViewComponent::Base
      def initialize(label = nil, **html_options)
        @label = label
        @html_options = { scope: "col" }.merge(html_options)
      end

      def call
        content_tag(:th, content || @label, **@html_options, class: ["table-head", @html_options[:class]].compact.join(" "))
      end
    end
  end
end
