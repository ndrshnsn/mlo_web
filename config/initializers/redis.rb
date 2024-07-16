Redis.new(
  url: Rails.application.credentials.dig(:redis, :host), port: Rails.application.credentials.dig(:redis, :host), db: Rails.application.credentials.dig(:redis, :db),
  timeout: ENV.fetch("REDIS_TIMEOUT", 1).to_i,
  reconnect_attempts: ENV.fetch("REDIS_RECONNECT_ATTEMPTS", 3).to_i
)
