# frozen_string_literal: true

module Ui
  # Coloured chip for tags and statuses. Colours are Tailwind colour names stored on the record ("blue", "red").
  #
  #   render Ui::TagComponent.new(tag.name, color: tag.color)                       # table cell
  #   render Ui::TagComponent.new(status.name, color: status.color, size: :md,
  #     remove: { id: "remove", data: { reflex: "click->EmployeeStatus#remove", "employee-id": employee.id } })
  #
  # `remove:` adds a small "x" button (aria-label "Remove <label>") with those HTML options.
  class TagComponent < ViewComponent::Base
    SIZES = {
      xs: "inline-flex px-2 text-xs font-semibold leading-5",
      sm: "inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium",
      md: "inline-flex items-center px-3 py-0.5 rounded-full text-sm font-medium",
    }.freeze

    def initialize(label = nil, color: "gray", size: :xs, remove: nil, **html_options)
      raise ArgumentError, "Unknown tag size #{size.inspect}" unless SIZES.key?(size)

      @label = label
      @color = color
      @size = size
      @remove = remove
      @html_options = html_options
    end

    def span_class
      ["#{SIZES.fetch(@size)} text-#{@color}-800 bg-#{@color}-100 rounded-full", @html_options[:class]].compact.join(" ")
    end

    def remove_options
      {
        type: "button",
        "aria-label": "Remove #{@label}",
        class: "flex-shrink-0 ml-0.5 h-4 w-4 rounded-full inline-flex items-center justify-center text-#{@color}-400 hover:bg-#{@color}-200 hover:text-#{@color}-400 focus:outline-none focus:bg-#{@color}-400 focus:text-white",
      }.merge(@remove)
    end
  end
end
