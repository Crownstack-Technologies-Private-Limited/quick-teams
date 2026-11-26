# frozen_string_literal: true

module Ui
  # Submit button with an optional "and do X" menu next to it (comment forms). Each option is another submit
  # input of the same form. Needs an ancestor with `data-controller="dropdown"` (the Stimulus dropdown).
  #
  #   render Ui::SplitSubmitButtonComponent.new(form, "Comment") do |button|
  #     button.with_option("and mark closed")
  #   end
  class SplitSubmitButtonComponent < ViewComponent::Base
    BUTTON = "cursor-pointer relative inline-flex items-center px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 hover:bg-gray-50 focus:z-10 focus:outline-none focus:ring-1 focus:ring-primary-500 focus:border-primary-500"
    OPTION = "cursor-pointer bg-white block w-full px-4 py-2 text-sm text-left text-gray-700 hover:bg-gray-50"

    renders_many :options, ->(label) { @form.submit(label, class: OPTION) }

    def initialize(form, label, button_id: "option-menu-button")
      @form = form
      @label = label
      @button_id = button_id
    end

    def main_button
      @form.submit(@label, class: "#{BUTTON} #{options? ? "rounded-l-md" : "rounded-md"}")
    end
  end
end
