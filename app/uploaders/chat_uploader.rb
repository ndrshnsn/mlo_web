
require 'image_processing/mini_magick'
class ChatUploader < Shrine
    plugin :data_uri
    plugin :add_metadata

    add_metadata do |io, context|
        {'filename' => context[:record].attachment_name}
    end

    Attacher.derivatives do |original|
        magick = ImageProcessing::MiniMagick.source(original)
        
        { 
            small:  magick.resize_to_limit!(180, 180),
            medium: magick.resize_to_limit!(260, 260),
            large:  magick.resize_to_limit!(400, 400),
        }
    end
end