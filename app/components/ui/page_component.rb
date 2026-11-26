# frozen_string_literal: true

module Ui
  # Outermost wrapper of a full page body (inside the layout's <main>).
  #
  #   render Ui::PageComponent.new { render "employee/title", employee: @employee ... }
  #   render Ui::PageComponent.new(tag: :div)
  class PageComponent < ViewComponent::Base
    def initialize(tag: :main, **html_options)
      @tag = tag
      @html_options = html_options
    end

    def call
      content_tag(@tag, content, **@html_options, class: ["relative z-0 flex-1 overflow-y-auto focus:outline-none", @html_options[:class]].compact.join(" "))
    end
  end
end
