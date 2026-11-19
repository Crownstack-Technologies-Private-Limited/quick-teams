# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# ruby version app is using, [https://www.ruby-lang.org/en/downloads/]
ruby "3.4.7"

# Bundle edge Rails instead: gem 'rails', [https://github.com/rails/rails]
gem "rails", "~> 8.1.4", ">= 8.1.4.1"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"

# Use postgresql as the database for Active Record [https://github.com/ged/ruby-pg]
gem "pg", "~> 1.5"

# Use Puma as the app server [https://github.com/puma/puma]
gem "puma", "~> 8.1"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails", "~> 4.4"

# Hotwire's SPA-like page accelerator [https://github.com/hotwired/turbo-rails]
gem "turbo-rails", "~> 2.0"

# Hotwire's modest JavaScript framework [https://github.com/hotwired/stimulus-rails]
gem "stimulus-rails", "~> 1.3"

# Build reactive applications [https://github.com/stimulusreflex/stimulus_reflex]
gem "stimulus_reflex", "~> 3.5"

# Use Active Storage variant
gem "image_processing", "~> 2.2"
# image_processing 2 no longer depends on mini_magick; variants use variant_processor :mini_magick
gem "mini_magick", "~> 5.4"

# Solid Queue for background jobs
gem "solid_queue", "~> 1.7"

# Solid Cable for Action Cable
gem "solid_cable", "~> 4.1"

# Reduces boot times through caching; required in config/boot.rb
gem "acts_as_tenant"
gem "aws-sdk-s3", "~> 1.170"
gem "bootsnap", "~> 1.18", require: false
gem "draper"
gem "pagy", "~> 43.0"
gem "rails-patterns"
gem "wicked_pdf", "~> 2.8"
gem "wkhtmltopdf-binary", "0.12.6.10"
gem "csv"
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "nokogiri", "~> 1.16"

# devise gems
gem "devise", "~> 5.0"
gem "devise_invitable", "~> 2.0", ">= 2.0.14" # 3.x moves invitations to their own table (Phase 4)
gem "pwned", "~> 2.4" # not_pwned: validator in SignUpForm / ChangePasswordForm

# Payments
gem "pay", "~> 11.4"
gem "stripe", "~> 18.0"

gem "newrelic_rpm", "~> 10.9"

group :development, :test do
  gem "brakeman", require: false
  gem "bundler-audit", require: false
  gem "debug"
  gem "faker"
  gem "letter_opener"
  gem "rack-mini-profiler"
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "letter_opener_web" # config.action_mailer.delivery_method = :letter_opener_web, UI at /letter_opener
  gem "web-console"
  gem "listen"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "mocha"
end
