class DbSeederJob < ApplicationJob
    queue_as :default

    ADMIN_EMAIL = ENV['ADMIN_USERNAME']
    ADMIN_PASSWORD = ENV['ADMIN_PASSWORD']
    ADMIN_FULLNAME = ENV['ADMIN_FULLNAME']

    def perform
        ActiveRecord::Base.transaction do
            default_app_config
            create_admin
        end
    end

    private

    def default_app_config
        AppConfig.mail_admin = ENV['GMAIL_USERNAME']
        AppConfig.mail_username = ENV['GMAIL_USERNAME']
        AppConfig.mail_password = ENV['GMAIL_PASSWORD']
        AppConfig.generic_player = 999999
        AppConfig.platforms = [["PES", ["PES21", "EFOOT24"]], ["FIFA", ["FIFA24"]]]
        AppConfig.fake_account_password = "asdasdasdasdas" 
        AppConfig.championship_minimum_players = 4
        AppConfig.championship_cards_suspension_ycard = 3
        AppConfig.championship_cards_suspension_rcard = 1
        AppConfig.match_winning_earning = 1000
        AppConfig.match_draw_earning = 500
        AppConfig.match_lost_earning = 500
        AppConfig.match_goal_earning = 100
        AppConfig.match_goal_loss = 50
        AppConfig.match_yellow_card_loss = 50
        AppConfig.match_red_card_loss = 100
        AppConfig.match_winning_ranking = 10
        AppConfig.match_draw_ranking = 5
        AppConfig.match_lost_ranking = 3
        AppConfig.match_winning_points = 3
        AppConfig.match_draw_points = 1
        AppConfig.match_lost_points = 0
        AppConfig.match_hattrick_earning = 100
        AppConfig.game_wo_winner = 3
        AppConfig.game_wo_loser = 0
        AppConfig.league_slots = [10, 20, 40, 60]
        AppConfig.season_times = [45, 60, 90, 120, 180]
        AppConfig.season_min_players = [16, 18, 20]
        AppConfig.season_max_players = [18, 20, 22, 24]
        AppConfig.season_max_steals_same_player = 3
        AppConfig.season_max_steals_per_user = 3
        AppConfig.season_max_stealed_players = 3
        AppConfig.season_default_steal_window_start = 0
        AppConfig.season_default_steal_window_end = 2
        AppConfig.season_default_player_earnings = 1000
        AppConfig.season_default_player_earnings_fixed = 1000
        AppConfig.season_default_mininum_operation = 100
        AppConfig.season_tax_for_fired_players = 10000
        AppConfig.season_default_time_game_confirmation = 2
        AppConfig.season_player_value_earning_relation = 10
        AppConfig.season_player_high_over = 80
        AppConfig.season_player_low_over = 70
        AppConfig.season_player_raffle_remaining = ["70-", "70+", "75-", "75+", "80-", "80+", "82-", "82+", "85-", "85+", "90-", "99-"]
        AppConfig.season_player_raffle_first_order = [["PES", ["GK", "GK", "RB", "LB", "CB", "CB", "CB", "DMF", "DMF", "CMF", "CMF", "AMF", "RWF", "LWF", "CF", "CF"]], ["FIFA", ["GK", "GK", "RB", "LB", "CB", "CB", "CB", "CDM", "CDM", "CM", "CM", "CAM", "RW", "LW", "ST", "ST"]]]
        AppConfig.season_club_default_earning = 10000
        AppConfig.season_club_max_total_wage = 100000
    end

    def create_admin
        user = User.create!(
            email: ADMIN_EMAIL,
            password: ADMIN_PASSWORD,
            password_confirmation: ADMIN_PASSWORD,
            role: 2,
            active: true,
            slug: ADMIN_FULLNAME
        )
        user.skip_confirmation!
        user.save!
    end
end