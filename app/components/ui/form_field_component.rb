# frozen_string_literal: true

module Ui
  # Label + control + help/error text, for controls the form builder does not wrap
  # (selects, checkboxes, custom controls). The control is the block content.
  #
  #   render Ui::FormFieldComponent.new(label: "Discipline", for_id: "employee_discipline_id", help: "Optional") do
  #     form.collection_select(:discipline_id, ...)
  #   end
  class FormFieldComponent < ViewComponent::Base
    def initialize(label: nil, for_id: nil, help: nil, error: nil)
      @label = label
      @for_id = for_id
      @help = help
      @error = error
    end
  end
end
