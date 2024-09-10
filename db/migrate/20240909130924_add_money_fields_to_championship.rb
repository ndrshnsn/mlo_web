class AddMoneyFieldsToChampionship < ActiveRecord::Migration[7.2]
  def change
    add_monetize :championships, :match_winning_earning, currency: { present: false }
    add_monetize :championships, :match_draw_earning, currency: { present: false }
    add_monetize :championships, :match_lost_earning, currency: { present: false }
    add_monetize :championships, :match_goal_earning, currency: { present: false }
    add_monetize :championships, :match_goal_lost, currency: { present: false }
    add_monetize :championships, :match_yellow_card_loss, currency: { present: false }
    add_monetize :championships, :match_red_card_loss, currency: { present: false }
    add_monetize :championships, :hattrick_earning, currency: { present: false }
  end
end
