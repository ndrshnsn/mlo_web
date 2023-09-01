require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.after_initialize do
    Bullet.enable        = true
    Bullet.alert         = false
    Bullet.bullet_logger = false
    Bullet.console       = false
    Bullet.rails_logger  = true
    Bullet.add_footer    = false
  end

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :redis_cache_store, {url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" }}
    config.session_store :cache_store, key: "_sessions_development", compress: true, pool_size: 5, expire_after: 1.year

  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # config.session_store :cache_store, key: "_sessions_development", compress: true, pool_size: 5, expire_after: 1.year

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
  #config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  config.action_view.preload_links_header = false

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.url = 'ws://app.mlo-dev.test/cable'
  # config.web_socket_server_url = 'ws://app.mlo-dev.test/cable'
  # config.action_cable.allowed_request_origins = [/http:\/\/*/, /https:\/\/*/]
  # config.action_cable.disable_request_forgery_protection = true
  # config.action_controller.action_on_unpermitted_parameters = :log

  config.playerdb_prefix = "http://127.0.0.1/playerdb"
  config.root_url = "https://dev.bifrost.com:3000"
  config.hosts << "dev.bifrost.com"
  config.force_ssl = true
  config.ssl_options = {hsts: false}
  config.web_console.permissions = "192.168.0.0/255.255.255.0"
end
