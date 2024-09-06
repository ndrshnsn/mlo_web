class ClubFinance < ApplicationRecord
  belongs_to :club
  belongs_to :source, polymorphic: true
  after_create :update_club_balance

  monetize :value_cents, as: :value

  private

  def update_club_balance
    if ClubFinance.where(club_id: club.id).count > 1
      current = 0
      previous_balance = ClubFinance.where(club_id: club.id).order("updated_at ASC").second_to_last.balance.to_money
      previous_balance = 0 if previous_balance.nil?
      current = ClubFinance.where(club_id: club.id).order("updated_at ASC").last

      case current.operation
      when "player_hire"
        updated_balance = previous_balance - current.value.to_money
      when "pay_wage"
        updated_balance = previous_balance - current.value.to_money
      when "clear_club_balance"
        updated_balance = current.value.to_money
      when "fire_tax"
        updated_balance = previous_balance - current.value.to_money
      when "player_steal"
        updated_balance = previous_balance - current.value.to_money
      when "player_sold"
        updated_balance = previous_balance + current.value.to_money
      when "player_stealed"
        updated_balance = previous_balance + current.value.to_money
      when "player_exchange"
        updated_balance = previous_balance + current.value.to_money
      when "game"
        updated_balance = previous_balance + current.value.to_money
      when "award"
        updated_balance = previous_balance + current.value.to_money
      end
      
      current.balance = updated_balance
      current.save!
    end
  end
end
