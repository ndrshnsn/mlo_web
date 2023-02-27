require "shrine" # core
require "shrine/storage/file_system"
#require 'shrine/storage/s3'

# s3_options = {
#   access_key_id: Rails.application.credentials.dig(:digitalocean, :mlospaceks),
#   secret_access_key: Rails.application.credentials.dig(:digitalocean, :secret),
#   bucket: 'cdn-mlo',
#   endpoint: 'https://sfo3.digitaloceanspaces.com',
#   region: 'sfo3'
# }

# Shrine.storages = {
#   cache: Shrine::Storage::S3.new(prefix: 'uploads/cache', upload_options: {acl: 'public-read'}, **s3_options),
#   store: Shrine::Storage::S3.new(prefix: 'uploads/store', upload_options: {acl: 'public-read'}, **s3_options),
# }

Shrine.storages = { 
  cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"), # temporary 
  store: Shrine::Storage::FileSystem.new("public", prefix: "uploads"),       # permanent 
}

Shrine.plugin :determine_mime_type # check MIME TYPE
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data
Shrine.plugin :validation_helpers, default_messages: {
    mime_type_inclusion: ->(whitelist) { # you may use whitelist variable to display allowed types
      "isn't of allowed type. It must be an image."
    }
}

Shrine::Attacher.validate do
  validate_mime_type_inclusion [ # whitelist only these MIME types
                                   'image/jpeg',
                                   'image/png',
                                   'image/gif'
                               ]
  validate_max_size 1.megabyte # limit file size to 1MB
end

Shrine.plugin :pretty_location
Shrine.plugin :activerecord # enable ActiveRecord support
Shrine.plugin :derivatives, create_on_promote: true # Save image in multiple versions
Shrine.plugin :backgrounding # Background processing
