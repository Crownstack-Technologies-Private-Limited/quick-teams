# frozen_string_literal: true

module Ui
  # Surface for lists, tables, settings panels. Wraps .card / .card-header / .card-title / .card-body.
  #
  #   render Ui::CardComponent.new(title: "Details") do |card|
  #     card.with_actions { render Ui::ButtonComponent.new("Edit", href: path, variant: :secondary, size: :sm) }
  #     "body content"
  #   end
  #
  # `padded: false` renders the content edge to edge (tables inside a card).
  class CardComponent < ViewComponent::Base
    renders_one :actions
    renders_one :footer


    def initialize(title: nil, padded: true, **html_options)
      @title = title
      @padded = padded
      @html_options = html_options
    end

    def wrapper_options
      @html_options.merge(class: ["card", @html_options[:class]].compact.join(" "))
    end
  end
end
