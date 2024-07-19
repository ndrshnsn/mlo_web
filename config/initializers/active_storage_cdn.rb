Rails.application.config.after_initialize do
  # require "active_storage/service/s3_service"

  # module SimpleCDNUrlReplacement
  #   CDN_HOST = "cdn.masterleagueonline.com.br"

  #   def url(...)
  #     url = super
  #     original_host = "#{bucket.name}.#{client.client.config.endpoint.host}"
  #     url.gsub(original_host, CDN_HOST)
  #   end
  # end

  # ActiveStorage::Service::S3Service.prepend(SimpleCDNUrlReplacement)
end
