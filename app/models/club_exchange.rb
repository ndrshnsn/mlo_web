class ClubExchange < ApplicationRecord
  belongs_to :from_club, class_name: "Club"
  belongs_to :to_club, class_name: "Club"

  # jsonb_accessor :from_details

  # jsonb_accessor :to_details,
  #   price: :integer

  # enum status: {}
end
