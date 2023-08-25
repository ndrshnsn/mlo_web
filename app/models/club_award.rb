class ClubAward < ApplicationRecord
  belongs_to :club
  belongs_to :source, polymorphic: true
end
