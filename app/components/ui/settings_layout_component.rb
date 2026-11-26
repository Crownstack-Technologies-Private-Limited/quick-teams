# frozen_string_literal: true

module Ui
  # Two-column settings page: side menu on the left, content on the right.
  #
  #   render Ui::SettingsLayoutComponent.new(menu: :account) do
  #     ...content...
  #   end
  #
  # menu: :account | :settings | :archive (the matching shared/*_menu partial)
  # width: :narrow (6 of 12 columns, default) or :wide (8 of 12)
  class SettingsLayoutComponent < ViewComponent::Base
    # Optional block rendered to the right of the content column (e.g. the avatar uploader).
    renders_one :aside_content

    MENUS = { account: "shared/account_menu", settings: "shared/settings_menu", archive: "shared/archive_menu" }.freeze
    WIDTHS = { narrow: "max-w-xl px-4 pb-12 lg:col-span-6", wide: "max-w-xl px-4 pb-12 lg:col-span-8", extra_wide: "max-w-3xl pb-12 lg:col-span-8" }.freeze

    def initialize(menu:, width: :narrow)
      raise ArgumentError, "Unknown settings menu #{menu.inspect}" unless MENUS.key?(menu)
      raise ArgumentError, "Unknown settings width #{width.inspect}" unless WIDTHS.key?(width)

      @menu = menu
      @width = width
    end

    def menu_partial = MENUS.fetch(@menu)

    def content_class = WIDTHS.fetch(@width)
  end
end
