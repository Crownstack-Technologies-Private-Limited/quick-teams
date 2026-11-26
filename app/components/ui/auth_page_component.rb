# frozen_string_literal: true

module Ui
  # Signed-out page shell: gradient background, brand mark, title (+ optional subtitle), then the form.
  #
  #   render Ui::AuthPageComponent.new(title: "Sign in to your account", heading_tag: :h1) do |page|
  #     page.with_subtitle { "Or #{link_to ...}" }
  #     render "form"
  #   end
  class AuthPageComponent < ViewComponent::Base
    renders_one :subtitle

    def initialize(title:, heading_tag: :h1)
      @title = title
      @heading_tag = heading_tag
    end
  end
end
