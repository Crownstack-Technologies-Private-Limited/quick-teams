# frozen_string_literal: true

module Ui
  # Overlapping row of avatars with an optional "+N" overflow label.
  #
  #   render Ui::AvatarGroupComponent.new(project.display_participants, size: :xs, overflow: project.display_additional_participants, title: names)
  class AvatarGroupComponent < ViewComponent::Base
    def initialize(people, size: :xs, overflow: nil, title: nil)
      @people = people
      @size = size
      @overflow = overflow
      @title = title
    end
  end
end
