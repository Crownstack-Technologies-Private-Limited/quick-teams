# frozen_string_literal: true

module Ui
  # Placeholder text shown inside a lazy turbo-frame until its content arrives.
  #
  #   turbo_frame_tag "events", src: events_path, loading: :lazy do
  #     render Ui::LoadingComponent.new("Hold on a sec while I fetch events...")
  #   end
  class LoadingComponent < ViewComponent::Base
    def initialize(message, **html_options)
      @message = message
      @html_options = html_options
    end

    def call
      content_tag(:p, @message, **@html_options, role: "status", class: ["pb-2 mt-1 text-sm text-gray-500 truncate", @html_options[:class]].compact.join(" "))
    end
  end
end
