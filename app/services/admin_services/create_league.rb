class AdminServices::CreateLeague < ApplicationService
  def initialize(league, params)
    @league = league
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      create_league
    end
  end

  private

  def create_league
    return OpenStruct.new(success?: false, league: nil, errors: @league.errors) unless @league.save!

    adm = User.find(@params[:user_id])
    if adm.update!(
      request: false,
      active_league: @league.id,
      role: "manager"
      )

      @league.slots.times do |i|
        create_fake = AppServices::CreateFake.call()
        if create_fake.user
          UserLeague.new(
            league_id: @league.id,
            user_id: create_fake.user.id,
            status: true
          ).save!
        end
      end

      AppServices::Sendmail.call("new_league", @league, {to: adm.email, league_name: @params[:name], full_name: adm.full_name})
    end
    OpenStruct.new(success?: true, league: @league, errors: nil)
  end
end


