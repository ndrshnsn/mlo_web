class ClubAward < ApplicationRecord
  belongs_to :club
  belongs_to :source, polymorphic: true
  belongs_to :championship_award, -> { where(club_awards: { source_type: 'ChampionshipAward'} ) }, foreign_key: 'source_id'
end
