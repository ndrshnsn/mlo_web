class GlobalNotification < ApplicationRecord
  belongs_to :league

  jsonb_accessor :params,
    type: :string,
    enabled: :boolean,
    expire: :datetime

  def self.get_valid(league_id)
    return GlobalNotification.where(league_id: league_id).where("(params ->> 'enabled')::Bool = ?", true)
  end

  def self.disable(league_id)
    return GlobalNotification.where(league_id: league_id).update_all("params = jsonb_set(params, '{enabled}', to_json('false'::Bool)::jsonb)")
  end
end
