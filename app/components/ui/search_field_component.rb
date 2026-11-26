# frozen_string_literal: true

module Ui
  # Search input with a live results panel, driven by the Stimulus `nav-search` controller
  # (it fetches `url` as you type and fills the `results` list).
  #
  #   render Ui::SearchFieldComponent.new(url: "/search/surveys", placeholder: "Search Survey")
  #   render Ui::SearchFieldComponent.new(url: "/search/users?project_id=1", id: "search-observers",
  #            label: "Search to add new observer", icon: false)
  #
  # variant: :form (regular input, default) or :navbar (compact grey field for the app bar).
  # `label:` renders a visible label; `sr_label:` a screen-reader-only one; otherwise `aria_label` names the input.
  class SearchFieldComponent < ViewComponent::Base
    NAVBAR_INPUT = "block w-full rounded-md border border-transparent bg-gray-100 py-1.5 pl-9 pr-3 text-sm leading-5 text-gray-900 placeholder-gray-500 transition-colors focus:border-primary-500 focus:bg-white focus:ring-2 focus:ring-primary-500/25 focus:outline-none"

    def initialize(url:, id: "search", placeholder: nil, aria_label: nil, label: nil, sr_label: nil, icon: true, variant: :form, wrapper_class: nil)
      @url = url
      @id = id
      @placeholder = placeholder
      @aria_label = aria_label
      @label = label
      @sr_label = sr_label
      @icon = icon
      @variant = variant
      @wrapper_class = wrapper_class
    end

    def input_class
      return NAVBAR_INPUT if @variant == :navbar

      @icon ? "pl-10 pr-3 form-text-field" : "form-text-field"
    end

    def icon_class = @variant == :navbar ? "h-4 w-4 text-gray-400" : "h-5 w-5 text-gray-400"
  end
end
