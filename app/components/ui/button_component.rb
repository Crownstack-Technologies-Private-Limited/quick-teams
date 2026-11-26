# frozen_string_literal: true

module Ui
  # Button or link-button. Wraps the .btn-* classes from app/assets/tailwind/application.css.
  #
  #   render Ui::ButtonComponent.new("New Project", href: new_project_path)
  #   render Ui::ButtonComponent.new("Cancel", href: projects_path, variant: :secondary, size: :sm)
  #   render Ui::ButtonComponent.new(href: edit_path, variant: :icon, "aria-label": "Edit") do
  #     render Ui::IconComponent.new(:search)
  #   end
  #   render Ui::ButtonComponent.new("Delete", href: path, variant: :inline_delete, data: { ... })
  #
  # With `href:` it renders an <a> (through link_to, so data-turbo-method etc. work); otherwise a <button>.
  class ButtonComponent < ViewComponent::Base
    VARIANTS = {
      primary: "btn-primary",
      secondary: "btn-secondary",
      danger: "btn-red",
      ghost: "btn-ghost",
      icon: "icon-btn",
      inline_edit: "btn-inline-edit",
      inline_delete: "btn-inline-delete",
      plain: nil, # caller supplies every class
    }.freeze
    SIZES = { md: nil, sm: "btn-sm" }.freeze

    def initialize(label = nil, href: nil, variant: :primary, size: :md, type: nil, **html_options)
      raise ArgumentError, "Unknown button variant #{variant.inspect}" unless VARIANTS.key?(variant)
      raise ArgumentError, "Unknown button size #{size.inspect}" unless SIZES.key?(size)

      @label = label
      @href = href
      @variant = variant
      @size = size
      @type = type
      @html_options = html_options
    end

    def call
      body = content || @label
      if @href
        link_to(body, @href, **options)
      else
        content_tag(:button, body, **options, type: @type || "button")
      end
    end

    private

    def options
      classes = [VARIANTS.fetch(@variant), SIZES.fetch(@size), @html_options[:class]].compact.join(" ")
      @html_options.merge(class: classes)
    end
  end
end
