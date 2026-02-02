require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SolCalculations
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.eager_load_paths << Rails.root.join("domain")

    # Validate required environment variables after initialization
    config.after_initialize do
      # Skip validation in asset precompilation and db tasks
      next if defined?(Rails::Console) || File.split($0).last == 'rake'

      required_env_vars = {
        'OPEN_AI_SECRET_KEY' => 'OpenAI API key for generating numerology descriptions'
      }

      missing_vars = required_env_vars.select { |key, _| ENV[key].blank? }

      if missing_vars.any?
        error_message = "Missing required environment variables:\n"
        missing_vars.each do |key, description|
          error_message += "  - #{key}: #{description}\n"
        end
        error_message += "\nPlease set these variables in your .env file or environment."

        raise error_message
      end
    end
  end
end
