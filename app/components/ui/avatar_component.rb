# frozen_string_literal: true

module Ui
  # User avatar: uploaded image, or initials on a brand tint. Same markup the AvatarHelper always produced.
  #
  #   render Ui::AvatarComponent.new(user, size: :sm)
  #
  # Sizes: :xs (28px) :sm (32px) :md (40px) :lg (160px).
  class AvatarComponent < ViewComponent::Base
    SIZES = {
      xs: { box: "w-7 h-7", text: "text-xs", resize: [40, 40] },
      sm: { box: "w-8 h-8", text: "text-sm", resize: [40, 40] },
      md: { box: "w-10 h-10", text: "text-lg", resize: [80, 80] },
      lg: { box: "w-40 h-40", text: "text-xl", resize: [160, 160] },
    }.freeze

    def initialize(resource, size: :sm)
      raise ArgumentError, "Unknown avatar size #{size.inspect}" unless SIZES.key?(size)

      @resource = resource
      @size = SIZES.fetch(size)
    end

    def call
      if @resource.avatar.attached?
        image_tag @resource.avatar.variant(resize_to_limit: @size[:resize]), class: "rounded-full object-cover #{@size[:box]}"
      else
        initials = content_tag(:span, initials_text, class: "#{@size[:text]} font-semibold text-primary-700 leading-none")
        content_tag(:span, initials, class: "inline-flex items-center justify-center rounded-full bg-primary-100 ring-2 ring-white #{@size[:box]}")
      end
    end

    private

    def initials_text
      (@resource.first_name[0, 1] + @resource.last_name[0, 1]).upcase
    end
  end
end
