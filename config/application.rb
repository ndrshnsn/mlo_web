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

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.eager_load_paths << Rails.root.join('lib')

    # Dont include all helpers
    config.action_controller.include_all_helpers = false

    # Don't generate system test files.
    config.generators.system_tests = nil

    ## Load nested Locales
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    #I18n.enforce_available_locales = true
    I18n.available_locales = %i[en pt-BR es]
    I18n.default_locale = 'pt-BR'
    config.i18n.fallbacks = true
    config.i18n.fallbacks = [:en, :'pt-BR', :es]

    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "America/Sao_Paulo"

    # Only attempt update on local machine
    if Rails.env.development?
      # Update version file from latest git tag
      File.open('config/version', 'w') do |file|
        file.write `git describe --tags --always` # or equivalent
      end
    end
    config.version = File.read('config/version')
    config.web_console.permissions = '192.168.0.0/255.255.255.0'
    
  end
end
