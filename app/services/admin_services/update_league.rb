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
    #pslots = @league.slots

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
    ### --- THIS NEEDS TO BE VERIFIED AGAIN
    # if @league.seasons.where(status: 1).size == 0 && pslots != @league.slots
    #   league_fake_users = UserLeague.get_fake_accounts(@league.id)
    #   if pslots < @league.slots
    #     new_fake_accounts = @league.slots - pslots
    #     new_fake_accounts.times do |i|
    #       create_fake = AppServices::Users::CreateFake.call
    #       if create_fake.success? && create_fake.user
    #         UserLeague.new(
    #           league_id: league.id,
    #           user_id: create_fake.user.id,
    #           status: true
    #         ).save!
    #       end
    #     end
    #   end
    # end
    OpenStruct.new(success?: true, league: @league, error: nil)
  end

  def handle_error(league, error)
    OpenStruct.new(success?: false, league: league, error: error)
  end
end
