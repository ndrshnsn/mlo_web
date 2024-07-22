class Admin::SettingsController < ApplicationController
  authorize_resource class: false
  breadcrumb "dashboard", :admin_settings_path, match: :exact
  breadcrumb "admin.settings.main", :admin_settings_path, match: :exact

  def index
  end

  def update
    setting_params.keys.each do |key|
      if AppConfig.get_field(key)[:type] == :array
       value = setting_params[key].split(" ")
      else
        value = setting_params[key].strip
      end
      AppConfig.send("#{key}=", value) unless setting_params[key].nil?
    end

    respond_to do |format|
      flash.now["success"] = t(".success")
      format.html { redirect_to admin_settings_path, notice: t(".success") }
      format.turbo_stream
    end
  end

  private

  def setting_params
    params.require(:app_config).permit(
      :season_times,
      :season_min_players,
      :season_max_players,
      :season_max_steals_same_player,
      :season_max_steals_per_user,
      :season_max_stealed_players,
      :season_default_steal_window_start,
      :season_default_steal_window_end,
      :season_default_player_earnings,
      :season_default_mininum_operation,
      :season_tax_for_fired_players,
      :season_default_time_game_confirmation,
      :season_player_value_earning_relation,
      :season_player_high_over,
      :season_player_low_over,
      :season_player_raffle_remaining,
      :season_player_raffle_first_order,
      :season_club_default_earning,
      :season_club_max_total_wage,
      :league_slots,
      :generic_player,
      :fake_account_password,
      :championship_minimum_players,
      :championship_cards_suspension_ycard,
      :championship_cards_suspension_rcard,
      :match_winning_earning,
      :match_draw_earning,
      :match_lost_earning,
      :match_goal_earning,
      :match_goal_loss,
      :match_yellow_card_loss,
      :match_red_card_loss,
      :match_winning_ranking,
      :match_draw_ranking,
      :match_lost_ranking,
      :match_winning_points,
      :match_draw_points,
      :match_lost_points,
      :match_hattrick_earning,
      :mail_username,
      :mail_password,
      :mail_admin
    )
  end
end
