# frozen_string_literal: true

module Ui
  # Checkbox with its explanatory label on one row. The checkbox itself (from the form builder) is the block.
  #
  #   render Ui::CheckboxFieldComponent.new(label: "Billable", for_id: "employee_billable") do
  #     form.check_box(:billable, class: Ui::CheckboxFieldComponent::INPUT_CLASS)
  #   end
  class CheckboxFieldComponent < ViewComponent::Base
    INPUT_CLASS = "form-check"

    def initialize(label:, for_id: nil, help: nil)
      @label = label
      @for_id = for_id
      @help = help
    end
  end
end
