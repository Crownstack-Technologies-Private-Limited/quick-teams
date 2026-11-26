# frozen_string_literal: true

module Ui
  # Centered page for a single card form (account edit, invitations): title row, optional subtitle and actions.
  #
  #   render Ui::FormPageComponent.new(title: "Edit User", subtitle: "Change your sign-in details.", max_width: "max-w-2xl") do |page|
  #     page.with_actions { render Ui::BackButtonComponent.new }
  #     form...
  #   end
  class FormPageComponent < ViewComponent::Base
    renders_one :actions

    def initialize(title:, subtitle: nil, max_width: "max-w-xl")
      @title = title
      @subtitle = subtitle
      @max_width = max_width
    end
  end
end
