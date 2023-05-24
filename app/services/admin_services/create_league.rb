class AdminServices::CreateLeague < ApplicationService
  def initialize(params)
    @params = params[:league_params]
  end

  def call
    ActiveRecord::Base.transaction do
      create_league
    end
  end

  private

  def create_league
    league = League.new(@params)
    return handle_error(nil, league&.error) unless league.save!

    adm = User.find(@params[:user_id])
    if adm.update!(
      request: false,
      active_league: league.id,
      role: "manager"
      )

      league.slots.times do |i|
        create_fake = AppServices::Users::CreateFake.call
        if create_fake.success? && create_fake.user
          UserLeague.new(
            league_id: league.id,
            user_id: create_fake.user.id,
            status: true
          ).save!
        end
      end
      OpenStruct.new(success?: true, league: league, error: nil)
    else
      handle_error(league, league&.error)
    end
  end

  def handle_error(league, error)
    OpenStruct.new(success?: false, league: league, error: error)
  end
end
