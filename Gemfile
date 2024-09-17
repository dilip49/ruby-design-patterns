# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.1.4"

gem "rails", "~> 7.1.3", ">= 7.1.3.4"

gem "bootsnap", require: false
gem "faraday"
gem "importmap-rails"
gem "jbuilder"
gem "puma", ">= 5.0"
gem "redis", ">= 4.0.1"
gem "sprockets-rails"
gem "sqlite3", "~> 1.4"
gem "stimulus-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "debug", platforms: %i[mri windows]
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "ffaker"
  gem "rspec-rails", require: true
  gem "rubocop-rails", require: false
end

group :development do
  gem "error_highlight", ">= 0.4.0", platforms: [:ruby]
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
