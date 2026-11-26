# frozen_string_literal: true

module Ui
  # Coloured status strip with an icon, a message and an optional action button (publish / complete / submit).
  # The reflex pages re-render it through a turbo wrapper, so the action carries its own `data-reflex` attributes.
  #
  #   render Ui::StatusBannerComponent.new(tone: :success) do |banner|
  #     banner.with_action("Reopen", data: { reflex: "click->TodoReflex#toggle_todo", id: todo.id })
  #     "This todo has been completed on #{date}"
  #   end
  #
  # tone: :success (green) or :info (blue). `color:` (a Tailwind colour name such as "green") replaces the background.
  class StatusBannerComponent < ViewComponent::Base
    TONES = {
      success: { bg: "bg-green-50", icon: :check_circle, icon_class: "text-green-400", text: "font-medium text-green-800", action: "text-green-700 hover:text-green-600" },
      info: { bg: "bg-blue-50", icon: :information_circle, icon_class: "text-blue-400", text: "text-blue-700", action: "text-blue-700 hover:text-blue-600" },
    }.freeze

    renders_one :action, ->(label, **html_options) { Action.new(label, @tone, **html_options) }

    def initialize(tone: :info, color: nil)
      raise ArgumentError, "Unknown banner tone #{tone.inspect}" unless TONES.key?(tone)

      @tone = TONES.fetch(tone)
      @color = color
    end

    def background = @color ? "bg-#{@color}-100" : @tone[:bg]

    class Action < ViewComponent::Base
      def initialize(label, tone, **html_options)
        @label = label
        @tone = tone
        @html_options = html_options
      end

      def call
        content_tag(:p, class: "mt-3 text-sm md:mt-0 md:ml-6") do
          content_tag(:button, @label, type: "button", **@html_options, class: ["font-medium cursor-pointer whitespace-nowrap", @tone[:action], @html_options[:class]].compact.join(" "))
        end
      end
    end
  end
end
