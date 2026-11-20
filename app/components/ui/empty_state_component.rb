# frozen_string_literal: true

module Ui
  # "Nothing here" block. Title + message, optional icon and action.
  #
  #   render Ui::EmptyStateComponent.new(title: "No result found", message: "No project has been created yet.")
  #   render(Ui::EmptyStateComponent.new(title: "No tickets", icon: :ticket)) { link_button }
  class EmptyStateComponent < ViewComponent::Base
    def initialize(title: "No result found", message: nil, icon: nil)
      @title = title
      @message = message
      @icon = icon
    end
  end
end
