# frozen_string_literal: true

module Ui
  # Small coloured dot for statuses (project status colour).
  #
  #   render Ui::StatusDotComponent.new(color: project.status&.color || "white")
  class StatusDotComponent < ViewComponent::Base
    def initialize(color: "gray", **html_options)
      @color = color
      @html_options = html_options
    end

    def call
      content_tag(:span, "", **@html_options, class: ["mr-2 w-2.5 h-2.5 font-semibold leading-5 bg-#{@color}-400 rounded-full", @html_options[:class]].compact.join(" "))
    end
  end
end
