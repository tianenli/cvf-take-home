require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/railtie"

Bundler.require(*Rails.groups)

module CvfApp
  class Application < Rails::Application
    config.load_defaults 7.1

    # API-only mode setup
    config.api_only = false  # We need views for ActiveAdmin

    # CORS configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'localhost:5173', '127.0.0.1:5173'
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          credentials: true
      end
    end

    # ActiveJob configuration
    config.active_job.queue_adapter = :sidekiq

    # Timezone
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Autoload lib directory
    config.autoload_paths << Rails.root.join('lib')
  end
end
