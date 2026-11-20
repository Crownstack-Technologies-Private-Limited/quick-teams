# frozen_string_literal: true

module Ui
  # Top-bar link (desktop) or mobile-menu link. Selected when it points at the current page.
  #
  #   render Ui::NavItemComponent.new("Projects", projects_path)
  #   render Ui::NavItemComponent.new("Projects", projects_path, mobile: true)
  class NavItemComponent < ViewComponent::Base
    def initialize(label, href, mobile: false, selected: nil)
      @label = label
      @href = href
      @mobile = mobile
      @selected = selected
    end

    def selected?
      @selected.nil? ? helpers.current_page?(@href) : @selected
    end

    def css_class
      if @mobile
        ["mobile-nav-link", ("bg-primary-50 text-primary-700" if selected?)].compact.join(" ")
      else
        selected? ? "nav-selected" : "nav-unselected"
      end
    end

    def call
      link_to(content || @label, @href, class: css_class, "aria-current": (selected? ? "page" : nil))
    end
  end
end
