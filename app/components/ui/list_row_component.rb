# frozen_string_literal: true

module Ui
  # One row of a simple list (account settings: disciplines, roles, tags...). Wrap in the turbo-frame yourself.
  #
  #   render Ui::ListRowComponent.new(title: role.name.titleize, subtitle: nil) do |row|
  #     row.with_leading { render Ui::StatusDotComponent.new(color: tag.color) }
  #     row.with_actions { edit_button(path) + delete_button(path) }
  #   end
  class ListRowComponent < ViewComponent::Base
    renders_one :leading
    renders_one :actions

    def initialize(title:, subtitle: nil)
      @title = title
      @subtitle = subtitle
    end
  end
end
