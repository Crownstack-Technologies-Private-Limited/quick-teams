# frozen_string_literal: true

module Ui
  # Heading + supporting text for a form or section (title/subtitle block above a form).
  #
  #   render Ui::SectionHeadingComponent.new(title: "Profile", subtitle: "Update your details")
  #
  # An optional block is rendered to the right of the heading (actions).
  class SectionHeadingComponent < ViewComponent::Base
    def initialize(title:, subtitle: nil, tag: :h1, **html_options)
      @title = title
      @subtitle = subtitle
      @tag = tag
      @html_options = html_options
    end
  end
end
