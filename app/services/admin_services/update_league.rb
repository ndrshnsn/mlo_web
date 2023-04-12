class AdminServices::UpdateLeague < ApplicationService
  def initialize(league, params)
    @league = league
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      update_league
    end
  end

  private

  def update_league
    padm = User.find(@league.user_id)
    return OpenStruct.new(success?: false, league: nil, errors: @league.errors) unless @league.update!(
      name: @params[:name],
      user_id: @params[:user_id],
      platform: @params[:platform],
      slots: @params[:slots],
      status: @params[:status]
    )

    adm = User.find(@params[:user_id])
    if padm.id != adm.id
      padm.update(
        active_league: nil,
        active: false,
        role: "user"
      )
      adm.update!(
        request: false,
        active_league: @league.id,
        role: "manager"
      )

      AppServices::Sendmail("new_league", @league, {to: adm.email, league_name: league_params[:name], full_name: adm.full_name})
    end
    OpenStruct.new(success?: true, league: @league, errors: nil)
  end
end
