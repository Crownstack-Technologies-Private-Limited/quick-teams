# frozen_string_literal: true

module Ui
  # Checkbox with its explanatory label on one row. The checkbox itself (from the form builder) is the block.
  #
  #   render Ui::CheckboxFieldComponent.new(label: "Billable", for_id: "employee_billable") do
  #     form.check_box(:billable, class: Ui::CheckboxFieldComponent::INPUT_CLASS)
  #   end
  class CheckboxFieldComponent < ViewComponent::Base
    INPUT_CLASS = "w-4 h-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500"

    def initialize(label:, for_id: nil)
      @label = label
      @for_id = for_id
    end
  end
end
