Redis.new(
  url: ENV["REDIS_URL"], port: ENV["REDIS_PORT"], db: ENV["REDIS_DB"],
  timeout: ENV.fetch("REDIS_TIMEOUT", 1).to_i,
  reconnect_attempts: ENV.fetch("REDIS_RECONNECT_ATTEMPTS", 3).to_i
)
