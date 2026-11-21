require_relative "boot"
require_relative "../lib/account_middleware"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Skia
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #

    config.autoload_lib ignore: %w[ assets ]

    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.middleware.use AccountMiddleware
    config.autoload_paths << "#{Rails.root}/lib"

    # Component previews at /rails/view_components (development only). See docs/ui-audit/components.md.
    config.view_component.previews.default_layout = "component_preview"
  end
end
