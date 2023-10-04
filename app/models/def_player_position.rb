class DefPlayerPosition < ApplicationRecord
  has_many :def_players

  def self.get_sorted(platform)
    all.where(platform: platform).order(order: :asc)
  end

end
