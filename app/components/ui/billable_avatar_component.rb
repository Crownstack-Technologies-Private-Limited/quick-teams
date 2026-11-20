# frozen_string_literal: true

module Ui
  # Medium avatar with a green (billable) / red (non billable) dot in the corner and a matching tooltip.
  #
  #   render Ui::BillableAvatarComponent.new(employee)
  class BillableAvatarComponent < ViewComponent::Base
    def initialize(employee, size: :md)
      @employee = employee
      @size = size
    end

    def billable? = @employee.billable?

    def title = billable? ? "Billable" : "Non Billable"

    def dot_color = billable? ? "green" : "red"
  end
end
