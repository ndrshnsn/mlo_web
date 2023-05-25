class AdminServices::UpdateLeague < ApplicationService
  def initialize(league, league_params)
    @league = league
    @params = league_params
  end

  def call
    ActiveRecord::Base.transaction do
      update_league
    end
  end

  private

  def update_league
    padm = User.find(@league.user_id)
    pslots = @league.slots

    return handle_error(nil, @league&.error) unless @league.update!(@params)

    adm = User.find(@params[:user_id])
    if padm.id != adm.id
      if UserLeague.where(user_id: padm.id).count > 1
        padm.preferences["active_league"] = UserLeague.where(user_id: padm.id).where.not(league_id: @league.id).first.id
      else
        padm.update(
          active_league: nil,
          active: false,
          role: "user"
        )
      end

      adm.update!(
        request: false,
        active_league: @league.id,
        role: "manager"
      )
    end

    ## Update Slots
    if pslots != @league.slots

    end
    OpenStruct.new(success?: true, league: @league, error: nil)
  end

  def handle_error(league, error)
    OpenStruct.new(success?: false, league: league, error: error)
  end
end
