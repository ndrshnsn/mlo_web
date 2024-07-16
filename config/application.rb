require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MloWeb
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Don't generate system test files.
    config.generators.system_tests = nil

    ## Load nested Locales
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]

    # I18n.enforce_available_locales = true
    I18n.available_locales = %i[en pt-BR es]
    I18n.default_locale = "pt-BR"
    config.i18n.fallbacks = true
    config.i18n.fallbacks = [:en, :"pt-BR", :es]

    config.active_job.queue_adapter = :sidekiq

    # Only attempt update on local machine
    if Rails.env.development?
      # Update version file from latest git tag
      File.write("config/version", `git describe --tags --always`)
    end
    config.version = File.read("config/version")
  end
end
