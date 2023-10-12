class ClubFinance < ApplicationRecord
  belongs_to :club
  belongs_to :source, polymorphic: true
  after_create :update_club_balance

  private

  def update_club_balance
    if ClubFinance.where(club_id: club.id).count > 1
      previousBalance = ClubFinance.where(club_id: club.id).order("updated_at ASC").second_to_last
      current = ClubFinance.where(club_id: club.id).order("updated_at ASC").last

      case current.operation
      when "player_hire"
        updatedBalance = previousBalance.balance - current.value
      when "pay_wage"
        updatedBalance = previousBalance.balance - current.value
      when "clear_club_balance"
        updatedBalance = current.value
      when "fire_tax"
        updatedBalance = previousBalance.balance - current.value
      when "player_steal"
        updatedBalance = previousBalance.balance - current.value
      when "player_sold"
        updatedBalance = previousBalance.balance + current.value
      when "player_stealed"
        updatedBalance = previousBalance.balance + current.value
      when "game"
        updatedBalance = previousBalance.balance + current.value
      when "award"
        updatedBalance = previousBalance.balance + current.value
      end
      current.balance = updatedBalance
      current.save!
    end
  end
end
