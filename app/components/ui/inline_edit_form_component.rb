# frozen_string_literal: true

module Ui
  # Inline edit row inside a turbo-frame: a bold title, then a row of fields and a submit button.
  # Render it inside `form_with`; the hidden fields go in the block of a `with_field`.
  #
  #   render Ui::InlineEditFormComponent.new(title: "Edit Ada's schedule") do |row|
  #     row.with_field { render Ui::FormFieldComponent.new(label: "Starts At") { form.date_field(:starts_at, class: "form-text-field") } }
  #     row.with_submit { render Ui::SubmitButtonComponent.new(form, "Save", class: "ml-2 mt-6") }
  #   end
  class InlineEditFormComponent < ViewComponent::Base
    renders_many :fields
    renders_one :submit

    def initialize(title:)
      @title = title
    end
  end
end
