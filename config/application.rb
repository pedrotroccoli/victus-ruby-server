require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Victus
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    config.autoload_paths << "#{Rails.root}/lib" 

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'https://app.victusjournal.com', 'https://dev.victusjournal.com', 'http://localhost:5275'

        resource '*',
          methods: %i[get post delete put patch options head],
          headers: %w[Origin Access-Control-Allow-Origin Content-Type Accept Authorization Origin,Accept X-Requested-With Access-Control-Request-Method Access-Control-Request-Headers],
          expose: %w[Origin Content-Type Accept Authorization Access-Control-Allow-Origin Access-Control-Allow-Origin Access-Control-Allow-Credentials],
          credentials: true
      end
    end
  end
end
