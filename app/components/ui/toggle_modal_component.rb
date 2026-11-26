# frozen_string_literal: true

module Ui
  # Dialog that is always in the page and is shown / hidden by a Stimulus controller toggling the `hidden`
  # class on it (the planner modals). For dialogs rendered into #modal on demand use Ui::ModalComponent.
  #
  #   render Ui::ToggleModalComponent.new(id: "jobCardModal", title: "Add Job Card", title_options: { data: { "daily-planner-target": "modalTitle" } }) do |modal|
  #     modal.with_header_actions { ... }
  #     "form..."
  #   end
  class ToggleModalComponent < ViewComponent::Base
    renders_one :header_actions

    def initialize(id:, title:, title_options: {})
      @id = id
      @title = title
      @title_options = title_options
    end

    def title_id = "#{@id}-title"
  end
end
