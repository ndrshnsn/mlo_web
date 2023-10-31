class ClubFinance < ApplicationRecord
  belongs_to :club
  belongs_to :source, polymorphic: true
  after_create :update_club_balance

  private

  def update_club_balance
    if ClubFinance.where(club_id: club.id).count > 1
      previous_balance = ClubFinance.where(club_id: club.id).order("updated_at ASC").second_to_last
      current = ClubFinance.where(club_id: club.id).order("updated_at ASC").last
      case current.operation
      when "player_hire"
        updated_balance = previous_balance.balance - current.value
      when "pay_wage"
        updated_balance = previous_balance.balance - current.value
      when "clear_club_balance"
        updated_balance = current.value
      when "fire_tax"
        updated_balance = previous_balance.balance - current.value
      when "player_steal"
        updated_balance = previous_balance.balance - current.value
      when "player_sold"
        updated_balance = previous_balance.balance + current.value
      when "player_stealed"
        updated_balance = previous_balance.balance + current.value
      when "player_exchange"
        updated_balance = previous_balance.balance + current.value
      when "game"
        updated_balance = previous_balance.balance + current.value
      when "award"
        updated_balance = previous_balance.balance + current.value
      end
      current.balance = updated_balance
      current.save!
    end
  end
end
