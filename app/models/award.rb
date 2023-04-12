class Award < ApplicationRecord
  belongs_to :league

  include TrophyUploader::Attachment(:trophy)
  include Hashid::Rails
end
