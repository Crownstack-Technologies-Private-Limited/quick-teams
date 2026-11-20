# frozen_string_literal: true

module Ui
  # "Back" secondary button (browser history by default).
  #
  #   render Ui::BackButtonComponent.new
  #   render Ui::BackButtonComponent.new(href: projects_path, class: "mr-2")
  class BackButtonComponent < ViewComponent::Base
    def initialize(label: "Back", href: "javascript:history.back()", **html_options)
      @label = label
      @href = href
      @html_options = html_options
    end

    def call
      render Ui::ButtonComponent.new(@label, href: @href, variant: :secondary, **@html_options)
    end
  end
end
